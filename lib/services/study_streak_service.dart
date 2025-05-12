import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudyStreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's study streak data
  Stream<List<int>> getStudyStreak() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore.collection('study_streaks').doc(userId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final studiedDays = data['studiedDays'] as List<dynamic>;
      return studiedDays.map((day) => day as int).toList();
    });
  }

  // Add a study day to the streak
  Future<void> addStudyDay() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final dayIndex = DateTime.now().weekday % 7;

    await _firestore.collection('study_streaks').doc(userId).set({
      'studiedDays': FieldValue.arrayUnion([dayIndex]),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
