import 'package:flutter/material.dart';
import '../models/qt_log.dart';
import '../models/prayer_request.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

enum ActiveTab { home, qt, prayer }

class AppProvider with ChangeNotifier {
  ActiveTab _activeTab = ActiveTab.home;

  ActiveTab get activeTab => _activeTab;

  void setActiveTab(ActiveTab tab) {
    _activeTab = tab;
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

  User? _user = currentUser; // Nullable to represent logged out state
  User? get user => _user;

  // Data State
  final List<QTLog> _qtLogs = List.from(initialQtLogs);
  List<QTLog> get qtLogs => _qtLogs;

  final List<PrayerRequest> _prayerRequests = List.from(initialPrayerRequests);
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
  void addPrayerRequest(PrayerRequest request) {
    _prayerRequests.insert(0, request);
    notifyListeners();
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
      );
      notifyListeners();
    }
  }

  // Auth Methods
  void login() {
    _user = currentUser;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
