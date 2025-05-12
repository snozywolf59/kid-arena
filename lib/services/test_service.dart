// Dart packages

// Flutter packages

// Pub packages
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project packages
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/models/student_answer.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _privateCollection = 'tests';
  final String _publicCollection = 'public_tests';
  final String _studentAnswersCollection = 'student_answers';

  // Create a new test
  Future<String> createTest(PrivateTest test) async {
    try {
      final docRef = await _firestore
          .collection(_privateCollection)
          .add(test.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create test: $e');
    }
  }

  // Get all tests for a teacher
  Stream<List<PrivateTest>> getTestsForTeacher() {
    final currentUser = _auth.currentUser;
    return _firestore
        .collection(_privateCollection)
        .where('teacherId', isEqualTo: currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PrivateTest.fromFirestore(doc))
              .toList();
        });
  }

  Future<List<PrivateTest>> getTestsForClass(String classId) async {
    final snapshot =
        await _firestore
            .collection(_privateCollection)
            .where('classId', isEqualTo: classId)
            .get();
    return snapshot.docs.map((doc) => PrivateTest.fromFirestore(doc)).toList();
  }

  // Update a test
  Future<void> updateTest(PrivateTest test) async {
    try {
      await _firestore
          .collection(_privateCollection)
          .doc(test.id)
          .update(test.toMap());
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  // Delete a test
  Future<void> deleteTest(String testId) async {
    try {
      await _firestore.collection(_privateCollection).doc(testId).delete();
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  // Get a single test by ID
  Future<PrivateTest?> getTestById(String testId) async {
    try {
      final doc =
          await _firestore.collection(_privateCollection).doc(testId).get();
      if (doc.exists) {
        return PrivateTest.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get test: $e');
    }
  }

  Future<void> submitTest(Test test, List<int> answers, int timeTaken) async {
    try {
      double score = 0;
      for (int i = 0; i < test.questions.length; i++) {
        if (test.questions[i].correctAnswer == answers[i]) {
          score++;
        }
      }
      score = score / test.questions.length;
      final studentAnswer = StudentAnswer(
        id: test.id,
        studentId: _auth.currentUser?.uid ?? '',
        answers: answers,
        testId: test.id,
        submittedAt: DateTime.now(),
        timeTaken: timeTaken,
      );
      final result = await _firestore.collection('student_answers').add({
        ...studentAnswer.toMap(),
        'score': double.parse(score.toStringAsFixed(2)),
      });
      if (result.id.isNotEmpty) {
        return;
      } else {
        throw Exception('Failed to submit test: No document ID returned');
      }
    } catch (e) {
      throw Exception('Failed to submit test: $e');
    }
  }

  Future<List<PrivateTest>> getTestsForStudent() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    // First get all classes where the student is enrolled
    final classesSnapshot =
        await _firestore
            .collection('classes')
            .where('students', arrayContains: currentUser.uid)
            .get();

    if (classesSnapshot.docs.isEmpty) return [];

    // Get all class IDs
    final classIds = classesSnapshot.docs.map((doc) => doc.id).toList();

    // Get all tests for these classes
    final testsSnapshot =
        await _firestore
            .collection(_privateCollection)
            .where('classId', whereIn: classIds)
            .get();

    return testsSnapshot.docs
        .map((doc) => PrivateTest.fromFirestore(doc))
        .toList();
  }

  //////////////////////////////
  //// PUBLIC TESTS SERVICE ////
  //////////////////////////////

  Future<List<PublicTest>> getPublicTestsBySubject(Subject subject) async {
    final snapshot =
        await _firestore
            .collection(_publicCollection)
            .where('subject', isEqualTo: subject.name)
            .get();
    return snapshot.docs.map((doc) => PublicTest.fromFirestore(doc)).toList();
  }

  Future<List<PublicTest>> getPublicTestsByGrade(int grade) async {
    final snapshot =
        await _firestore
            .collection(_publicCollection)
            .where('grade', isEqualTo: grade)
            .get();
    return snapshot.docs.map((doc) => PublicTest.fromFirestore(doc)).toList();
  }

  // Get student answers for public tests
  Future<List<StudentAnswer>> getStudentAnswersForPublicTests(
    String studentId,
  ) async {
    final snapshot =
        await _firestore
            .collection(_studentAnswersCollection)
            .where('studentId', isEqualTo: studentId)
            .orderBy('score', descending: true)
            .get();
    return snapshot.docs
        .map((doc) => StudentAnswer.fromFirestore(doc))
        .toList();
  }

  // Get student answer for a specific public test
  Future<StudentAnswer?> getStudentAnswerForAPublicTest(
    String studentId,
    String testId,
  ) async {
    final snapshot =
        await _firestore
            .collection(_studentAnswersCollection)
            .where('studentId', isEqualTo: studentId)
            .where('testId', isEqualTo: testId)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return StudentAnswer.fromFirestore(snapshot.docs.first);
  }

  //submit student answer for a public test
  Future<void> submitStudentAnswerForAPublicTest(
    String testId,
    int timeTaken,
    List<int> answers,
    double score,
  ) async {
    try {
      final studentId = _auth.currentUser?.uid ?? '';
      final studentAnswer = StudentAnswer(
        id: '',
        studentId: studentId,
        answers: answers,
        testId: testId,
        submittedAt: DateTime.now(),
        timeTaken: timeTaken,
      );

      final result = await _firestore.collection(_studentAnswersCollection).add(
        {...studentAnswer.toMap(), 'score': score},
      );
      if (result.id.isNotEmpty) {
        return;
      } else {
        throw Exception('Failed to submit student answer for a public test');
      }
    } catch (e) {
      throw Exception('Failed to submit student answer for a public test: $e');
    }
  }
}
