import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prayer_request.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';

class PrayerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'harumanna');
  
  // Use subcollection: groups/{groupId}/prayers
  
  static Future<void> addPrayer(String groupId, PrayerRequest prayer) async {
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('prayers')
          .doc(prayer.id)
          .set(prayer.toMap()..addAll({
            'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
          }));
    } catch (e) {
      throw '기도 요청 저장 중 오류가 발생했습니다: $e';
    }
  }

  static Future<List<PrayerRequest>> getPrayers(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('prayers')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PrayerRequest.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting prayers: $e');
      return [];
    }
  }

  // Helper to toggle amen (later)
}

