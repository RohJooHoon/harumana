import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  // Use specific database 'harumanna'
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'harumanna');
  static final CollectionReference<Map<String, dynamic>> _groupsCollection = 
      _firestore.collection('groups');

  /// Create a new group
  static Future<String> createGroup({
    required String name,
    required String adminId,
    String? password, // Optional: null if not set
    String adminTitle = '목사님',
    String userTitle = '성도님',
    bool isAutoJoin = false,
  }) async {
    try {
      final docRef = _groupsCollection.doc();
      
      final group = Group(
        id: docRef.id,
        name: name,
        adminId: adminId,
        password: password,
        adminTitle: adminTitle,
        userTitle: userTitle,
        isAutoJoin: isAutoJoin,
      );

      await docRef.set(group.toMap()..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }));

      return docRef.id;
    } catch (e) {
      throw '그룹 생성 중 오류가 발생했습니다: $e';
    }
  }

  /// Get group by ID
  static Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _groupsCollection.doc(groupId).get();
      if (doc.exists && doc.data() != null) {
        return Group.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting group: $e');
      return null;
    }
  }
  /// Update group details
  static Future<void> updateGroup(Group group) async {
    try {
      await _groupsCollection.doc(group.id).update(group.toMap()..addAll({
        'updatedAt': FieldValue.serverTimestamp(),
      }));
    } catch (e) {
      throw '그룹 정보 수정 중 오류가 발생했습니다: $e';
    }
  }
  /// Get all groups
  static Future<List<Group>> getAllGroups() async {
    try {
      final snapshot = await _groupsCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Group.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting all groups: $e');
      return [];
    }
  }
}
