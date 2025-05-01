import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/test.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tests';

  // Create a new test
  Future<String> createTest(Test test) async {
    try {
      final docRef = await _firestore.collection(_collection).add(test.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create test: $e');
    }
  }

  // Get all tests for a teacher
  Stream<List<Test>> getTestsForTeacher(String teacherId) {
    return _firestore
        .collection(_collection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Test.fromFirestore(doc)).toList();
        });
  }

  // Update a test
  Future<void> updateTest(Test test) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(test.id)
          .update(test.toMap());
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  // Delete a test
  Future<void> deleteTest(String testId) async {
    try {
      await _firestore.collection(_collection).doc(testId).delete();
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  // Get a single test by ID
  Future<Test?> getTestById(String testId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(testId).get();
      if (doc.exists) {
        return Test.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get test: $e');
    }
  }
}
