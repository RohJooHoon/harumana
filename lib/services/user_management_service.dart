import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';
import 'user_service.dart';

class UserManagementService {
  // Use existing UserService _usersCollection if accessible, or create new reference
  // Since UserService _usersCollection is private, we will use UserService public methods or create new queries here.
  // Ideally, add these methods to UserService, but to keep changes focused, we can access Firestore directly here or extend UserService.
  // Actually, let's just use Firestore instance here for query efficiency.
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'harumanna');

  static Future<List<User>> getMembers(String groupId) async {
    try {
      final snapshot = await _firestore.collection('users')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting members: $e');
      return [];
    }
  }

  static Future<List<User>> getPendingMembers(String groupId) async {
    try {
      final snapshot = await _firestore.collection('users')
          .where('pendingGroupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting pending members: $e');
      return [];
    }
  }

  static Future<void> approveUser(String userId, String groupId) async {
    await _firestore.collection('users').doc(userId).update({
      'groupId': groupId,
      'pendingGroupId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> rejectUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'pendingGroupId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

