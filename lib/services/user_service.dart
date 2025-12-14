import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserService {
  // Use specific database 'harumanna'
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'harumanna');
  static final CollectionReference<Map<String, dynamic>> _usersCollection = 
      _firestore.collection('users');

  /// Create a new user document in Firestore with detailed fields
  static Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    UserRole role = UserRole.user,
    String? groupId,
    String? groupName,
    String? adminName,
    String? userName,
  }) async {
    final deviceId = await _getDeviceId();
    
    // Convert Role Enum to Auth String logic is handled in User model helper, 
    // but here we construct the map manually for explicit control or use User.toMap()
    // Let's explicitly construct to ensure requested fields are set correctly.

    final String authType = role.toAuthString; // SUPER, ADMIN, USER

    await _usersCollection.doc(uid).set({
      'email': email,
      'displayName': name, // name -> displayName
      'photoURL': photoUrl, // null if not provided
      'auth': authType,    // role -> auth
      
      'groupId': groupId,
      'groupName': groupName,
      'adminName': adminName, // 호칭 (관리자용)
      'userName': userName,   // 호칭 (사용자용)
      
      'deviceId': deviceId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      
      // Additional fields from reference project might include:
      // 'coins': 0, 'paid': false, etc. if needed later.
    });
  }

  /// Get simplified device ID
  static Future<String> _getDeviceId() async {
    String deviceIdentifier = 'unknown';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        deviceIdentifier = webInfo.vendor! + webInfo.userAgent! + webInfo.hardwareConcurrency.toString();
      } else if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceIdentifier = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceIdentifier = iosInfo.identifierForVendor ?? 'unknown_ios';
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        deviceIdentifier = linuxInfo.machineId ?? 'unknown_linux';
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        deviceIdentifier = macOsInfo.systemGUID ?? 'unknown_macos';
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        deviceIdentifier = windowsInfo.deviceId;
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return deviceIdentifier;
  }

  /// Get user by UID
  static Future<User?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  // Update helpers...
  static Future<void> updateUserName(String uid, String name) async {
    await _usersCollection.doc(uid).update({'displayName': name});
  }
  
  static Future<void> updateUserAvatar(String uid, String photoUrl) async {
    await _usersCollection.doc(uid).update({'photoURL': photoUrl});
  }
  /// Get all users (for Super Admin)
  static Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
  /// Update User Role
  static Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _usersCollection.doc(uid).update({'auth': newRole.toAuthString});
  }

  /// Delete User (Firestore Document only - Auth deletion requires separate Admin SDK or Cloud Function in real production)
  static Future<void> deleteUser(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}
