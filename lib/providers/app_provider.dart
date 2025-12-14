
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/qt_log.dart';
import '../models/prayer_request.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../data/mock_data.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/group_service.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';

enum ActiveTab { home, qt, prayer, settings }

class AppProvider with ChangeNotifier {
  ActiveTab _activeTab = ActiveTab.home;
  bool _isInitialized = false;
  bool _isLoading = false;
  StreamSubscription<fb.User?>? _authSubscription;

  ActiveTab get activeTab => _activeTab;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  void setActiveTab(ActiveTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // Auth & RBAC State
  User? _user;
  User? get user => _user;

  UserRole _currentMode = UserRole.user; // Default mode is USER
  UserRole get currentMode => _currentMode;
  bool get isAdminMode => _currentMode == UserRole.admin || _currentMode == UserRole.superAdmin;
  
  Group? _currentGroup;
  Group? get currentGroup => _currentGroup;

  // 가입 대기 상태 확인
  bool get isPendingGroupApproval => _user?.pendingGroupId != null && _user?.groupId == null;
  bool get hasNoGroup => _user?.groupId == null && _user?.pendingGroupId == null;
  bool get hasGroup => _user?.groupId != null;

  AppProvider() {
    _initializeAuth();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Initialize Firebase Auth state listener
  Future<void> _initializeAuth() async {
    _isLoading = true;
    
    // Listen to auth state changes
    _authSubscription = AuthService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // User is signed in - fetch user data from Firestore
        await _loadUserFromFirestore(firebaseUser.uid);
      } else {
        // User is signed out
        _user = null;
        _currentGroup = null;
        _currentMode = UserRole.user;
        _activeTab = ActiveTab.home;
      }
      
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final firestoreUser = await UserService.getUser(uid);
      if (firestoreUser != null) {
        _user = firestoreUser;
        await _initializeGroup(); // Now async
        _currentMode = firestoreUser.role; // Start in assigned role mode

        // Save FCM token for push notifications
        await NotificationService().saveTokenToUser(uid);
      } else {
        // User exists in Auth but not in Firestore
        // This can happen if Firestore write failed during signup
        _user = null;
      }
    } catch (e) {
      debugPrint('Error loading user from Firestore: $e');
      _user = null;
    }
  }

  /// Refresh current user from Firestore (call after signup or profile update)
  Future<void> refreshCurrentUser() async {
    final firebaseUser = AuthService.currentUser;
    if (firebaseUser != null) {
      await _loadUserFromFirestore(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<void> _initializeGroup() async {
    debugPrint('[_initializeGroup] user: $_user, groupId: ${_user?.groupId}');

    if (_user?.groupId != null) {
      try {
        debugPrint('[_initializeGroup] Loading group: ${_user!.groupId}');
        final group = await GroupService.getGroup(_user!.groupId!);
        debugPrint('[_initializeGroup] Loaded group: $group');

        if (group != null) {
          _currentGroup = group;
          debugPrint('[_initializeGroup] currentGroup set: ${_currentGroup?.name}');
        } else {
          debugPrint('[_initializeGroup] Group not found in Firestore!');
        }

        if (_currentGroup != null) {
          await _loadPrayers();
        }
      } catch (e) {
        debugPrint('[_initializeGroup] Error loading group: $e');
        _currentGroup = null;
      }
    } else {
      debugPrint('[_initializeGroup] No groupId on user, skipping group load');
      _currentGroup = null;
    }
  }

  Future<void> updateGroup(Group updatedGroup) async {
    if (_currentGroup != null && _currentGroup!.id == updatedGroup.id) {
      try {
        await GroupService.updateGroup(updatedGroup);
        _currentGroup = updatedGroup;
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating group: $e');
        rethrow;
      }
    }
  }

  void changeMode(UserRole newMode) {
    // Only allow mode changes if user has permission
    if (_user == null) return;
    
    // SuperAdmin can switch to anything.
    // Admin can switch to Admin or User.
    // User can only be User (but UI shouldn't allow the switch anyway).
    
    _currentMode = newMode;
    // Reset to approriate home tab
    if (isAdminMode) {
      _activeTab = ActiveTab.qt;
    } else {
      _activeTab = ActiveTab.home;
    }
    notifyListeners();
  }

  int get streak {
    if (_user == null) return 0;
    
    // Filter my logs
    final myLogs = _qtLogs.where((l) => l.userId == _user!.id).toList();
    if (myLogs.isEmpty) return 0;
    
    final userDates = myLogs.map((l) => l.date).toSet();
    DateTime checkDate = DateTime.now();
    
    // Check if streak is active (Today or Yesterday present)
    String dateStr = checkDate.toIso8601String().substring(0, 10);
    if (!userDates.contains(dateStr)) {
      // If today not present, check yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
      dateStr = checkDate.toIso8601String().substring(0, 10);
      if (!userDates.contains(dateStr)) {
        return 0; // Streak broken
      }
    }
    
    // Count consecutive days backwards
    int currentStreak = 0;
    while (true) {
      String dStr = checkDate.toIso8601String().substring(0, 10);
      if (userDates.contains(dStr)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return currentStreak;
  }

  // Data State
  final List<QTLog> _qtLogs = List.from(initialQtLogs);
  List<QTLog> get qtLogs => _qtLogs;

  final List<PrayerRequest> _prayerRequests = [];
  List<PrayerRequest> get prayerRequests => _prayerRequests;

  // QT Logic
  void addQTLog(QTLog log) {
    _qtLogs.insert(0, log);
    notifyListeners();
  }

  void updateQTLog(QTLog updatedLog) {
    final index = _qtLogs.indexWhere((log) => log.id == updatedLog.id);
    if (index != -1) {
      _qtLogs[index] = updatedLog;
      notifyListeners();
    }
  }

  // Prayer Logic
  Future<void> _loadPrayers() async {
    if (_currentGroup == null) return;
    try {
      final prayers = await PrayerService.getPrayers(_currentGroup!.id);
      _prayerRequests.clear();
      _prayerRequests.addAll(prayers);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading prayers: $e');
    }
  }

  Future<void> addPrayerRequest(PrayerRequest request) async {
    debugPrint('[addPrayerRequest] currentGroup: $_currentGroup, user: $_user, groupId: ${_user?.groupId}');

    if (_currentGroup == null) {
      debugPrint('[addPrayerRequest] currentGroup is null! Cannot add prayer.');
      throw '그룹에 속해있지 않습니다. 먼저 그룹에 가입해주세요.';
    }

    try {
      debugPrint('[addPrayerRequest] Saving to Firestore... groupId: ${_currentGroup!.id}');
      // Save to Firestore
      await PrayerService.addPrayer(_currentGroup!.id, request);
      debugPrint('[addPrayerRequest] Saved successfully!');

      // Update local state (Optimistic or wait for Stream? For now, manual add)
      // Note: If we implement Stream later, this might duplicate.
      // But user requested "insert into groups data", so Firestore is priority.
      _prayerRequests.insert(0, request);
      notifyListeners();
    } catch (e) {
      debugPrint('[addPrayerRequest] Error: $e');
      rethrow;
    }
  }

  void toggleAmen(String id) {
    final index = _prayerRequests.indexWhere((req) => req.id == id);
    if (index != -1) {
      final req = _prayerRequests[index];
      final isAmened = !req.isAmenedByMe;
      final newCount = isAmened ? req.amenCount + 1 : req.amenCount - 1;

      // Create new object to trigger update if needed
      _prayerRequests[index] = PrayerRequest(
        id: req.id,
        userId: req.userId,
        userName: req.userName,
        userAvatar: req.userAvatar,
        content: req.content,
        createdAt: req.createdAt,
        amenCount: newCount,
        isAmenedByMe: isAmened,
        type: req.type,
        isRead: (req.type == 'ONE_ON_ONE' && isAmened) ? true : req.isRead,
      );
      notifyListeners();
    }
  }

  // Auth Methods - Legacy login for backward compatibility
  void login() {
    // This is now handled by Firebase Auth listener
    // Keep for backward compatibility during transition
    _user = currentUser; // Use mock user as fallback
    _initializeGroup();
    _currentMode = UserRole.user;
    notifyListeners();
  }

  Future<void> logout() async {
    // Remove FCM token before logout
    if (_user != null) {
      await NotificationService().removeTokenFromUser(_user!.id);
    }

    await AuthService.signOut();
    _user = null;
    _currentGroup = null;
    _currentMode = UserRole.user;
    _activeTab = ActiveTab.home;
    notifyListeners();
  }

  /// Update user name in Firestore and local state
  Future<void> updateUserName(String newName) async {
    if (_user != null) {
      try {
        await UserService.updateUserName(_user!.id, newName);
        _user = User(
          id: _user!.id,
          email: _user!.email,
          name: newName,
          avatarUrl: _user!.avatarUrl,
          role: _user!.role,
          groupId: _user!.groupId,
          groupName: _user!.groupName,
          adminName: _user!.adminName,
          userName: _user!.userName,
          deviceId: _user!.deviceId,
          createdAt: _user!.createdAt,
          pendingGroupId: _user!.pendingGroupId,
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating user name: $e');
        rethrow;
      }
    }
  }

  /// Update user avatar in Firestore and local state
  Future<void> updateUserAvatar(String avatarUrl) async {
    if (_user != null) {
      try {
        await UserService.updateUserAvatar(_user!.id, avatarUrl);
        _user = User(
          id: _user!.id,
          email: _user!.email,
          name: _user!.name,
          avatarUrl: avatarUrl,
          role: _user!.role,
          groupId: _user!.groupId,
          groupName: _user!.groupName,
          adminName: _user!.adminName,
          userName: _user!.userName,
          deviceId: _user!.deviceId,
          createdAt: _user!.createdAt,
          pendingGroupId: _user!.pendingGroupId,
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating user avatar: $e');
        rethrow;
      }
    }
  }

  /// Update user's group (change to a different group)
  /// Returns true if directly joined, false if pending approval
  Future<bool> updateUserGroupId(String newGroupId) async {
    if (_user == null) return false;

    try {
      // Load the new group info to check isAutoJoin
      final newGroup = await GroupService.getGroup(newGroupId);
      if (newGroup == null) {
        throw '그룹을 찾을 수 없습니다.';
      }

      // 이미 인증되지 않은 상태(pendingGroupId가 있고 groupId가 없음)인 경우,
      // 새 그룹도 무조건 pending 상태로 설정 (isAutoJoin 여부 무관)
      final bool isCurrentlyPending = _user!.pendingGroupId != null && _user!.groupId == null;

      // Check if group allows auto-join (only for currently approved users)
      if (newGroup.isAutoJoin && !isCurrentlyPending) {
        // Direct join - update groupId (only if user was already approved)
        await UserService.updateUserGroup(_user!.id, newGroupId);

        _user = User(
          id: _user!.id,
          email: _user!.email,
          name: _user!.name,
          avatarUrl: _user!.avatarUrl,
          role: _user!.role,
          groupId: newGroupId,
          groupName: newGroup.name,
          adminName: _user!.adminName,
          userName: _user!.userName,
          deviceId: _user!.deviceId,
          createdAt: _user!.createdAt,
          pendingGroupId: null,
        );

        _currentGroup = newGroup;

        // Reload prayers for the new group
        await _loadPrayers();

        notifyListeners();
        return true;
      } else {
        // Requires approval - set pendingGroupId
        // (either group doesn't allow auto-join OR user is currently pending)
        await UserService.setPendingGroup(_user!.id, newGroupId);

        // Send notification to admin
        await NotificationService().createPendingApprovalNotification(
          groupId: newGroupId,
          userId: _user!.id,
          userName: _user!.name,
        );

        _user = User(
          id: _user!.id,
          email: _user!.email,
          name: _user!.name,
          avatarUrl: _user!.avatarUrl,
          role: _user!.role,
          groupId: null,
          groupName: null,
          adminName: _user!.adminName,
          userName: _user!.userName,
          deviceId: _user!.deviceId,
          createdAt: _user!.createdAt,
          pendingGroupId: newGroupId,
        );

        _currentGroup = null;
        _prayerRequests.clear();

        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating user group: $e');
      rethrow;
    }
  }

  /// Get all available groups
  Future<List<Group>> getAllGroups() async {
    return await GroupService.getAllGroups();
  }

  /// Clear user's group (become individual user without group)
  Future<void> clearUserGroup() async {
    if (_user == null) return;

    try {
      await UserService.clearUserGroup(_user!.id);

      _user = User(
        id: _user!.id,
        email: _user!.email,
        name: _user!.name,
        avatarUrl: _user!.avatarUrl,
        role: _user!.role,
        groupId: null,
        groupName: null,
        adminName: null,
        userName: null,
        deviceId: _user!.deviceId,
        createdAt: _user!.createdAt,
        pendingGroupId: null,
      );

      _currentGroup = null;
      _prayerRequests.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user group: $e');
      rethrow;
    }
  }
}
