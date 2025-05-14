import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'activities';

  Future<void> addRecentActivity(String activityType, String activityId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User ID is null');
    }
    //nếu chưa có doc với userId thì tạo mới
    final recentActivityRef = _firestore.collection(_collection).doc(userId);
    if (!(await recentActivityRef.get()).exists) {
      await recentActivityRef.set({
        'activities': [],
      });
    }

    await recentActivityRef.collection('activities').add({
      'activityType': activityType,
      'activityId': activityId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}