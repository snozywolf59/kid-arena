import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/student_answer.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _studentAnswerForPublicTestsCollection = 'student_answers';
  final String _publicTestsCollection = 'public_tests';

  final String _studentAnswerForPrivateTestsCollection =
      'student_answers_for_assigned_test';
  final String _assignedTestsCollection = 'tests';

  final String _classCollection = 'classes';

  // Helper method to get public test IDs by subject
  Future<List<String>> _getPublicTestIdsBySubject(Subject subject) async {
    final QuerySnapshot result =
        await _firestore
            .collection(_publicTestsCollection)
            .where('subject', isEqualTo: subject.name)
            .get();

    return result.docs.map((doc) => doc.id).toList();
  }

  // Get total score rankings for public tests by subject
  Future<List<Map<String, dynamic>>> getPublicTestTotalScoreRankings(
    Subject subject,
  ) async {
    try {
      final List<String> testIds = await _getPublicTestIdsBySubject(subject);

      final QuerySnapshot result =
          await _firestore
              .collection(_studentAnswerForPublicTestsCollection)
              .where('testId', whereIn: testIds)
              .get();

      // Group by studentId and calculate total scores
      final Map<String, double> studentTotalScores = {};
      final Map<String, int> studentTestCounts = {};

      for (var doc in result.docs) {
        final StudentAnswer answer = StudentAnswer.fromFirestore(doc);
        studentTotalScores[answer.studentId] =
            (studentTotalScores[answer.studentId] ?? 0) + answer.score;
        studentTestCounts[answer.studentId] =
            (studentTestCounts[answer.studentId] ?? 0) + 1;
      }

      // Calculate average scores and create ranking list
      final List<Map<String, dynamic>> rankings =
          studentTotalScores.entries.map((entry) {
            return {
              'studentId': entry.key,
              'totalScore': entry.value.toInt(),
              'averageScore':
                  (entry.value / studentTestCounts[entry.key]!).toDouble(),
              'testCount': studentTestCounts[entry.key],
            };
          }).toList();

      // Sort by total score in descending order
      rankings.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));

      return rankings;
    } catch (e) {
      throw Exception('Failed to get public test total score rankings: $e');
    }
  }

  // Get total wrong answers rankings for public tests by subject
  Future<List<Map<String, dynamic>>> getPublicTestTotalWrongAnswersRankings(
    Subject subject,
  ) async {
    try {
      final List<String> testIds = await _getPublicTestIdsBySubject(subject);

      final QuerySnapshot result =
          await _firestore
              .collection(_studentAnswerForPublicTestsCollection)
              .where('testId', whereIn: testIds)
              .get();

      // Group by studentId and calculate total wrong answers
      final Map<String, int> studentTotalWrongAnswers = {};
      final Map<String, int> studentTestCounts = {};

      for (var doc in result.docs) {
        final StudentAnswer answer = StudentAnswer.fromFirestore(doc);
        studentTotalWrongAnswers[answer.studentId] =
            (studentTotalWrongAnswers[answer.studentId] ?? 0) +
            answer.numOfWrongAnswers;
        studentTestCounts[answer.studentId] =
            (studentTestCounts[answer.studentId] ?? 0) + 1;
      }

      // Create ranking list
      final List<Map<String, dynamic>> rankings =
          studentTotalWrongAnswers.entries.map((entry) {
            return {
              'studentId': entry.key,
              'totalWrongAnswers': entry.value,
              'averageWrongAnswers':
                  (entry.value / studentTestCounts[entry.key]!).toDouble(),
              'testCount': studentTestCounts[entry.key],
            };
          }).toList();

      // Sort by total wrong answers in ascending order (fewer wrong answers is better)
      rankings.sort(
        (a, b) => a['totalWrongAnswers'].compareTo(b['totalWrongAnswers']),
      );

      return rankings;
    } catch (e) {
      throw Exception(
        'Failed to get public test total wrong answers rankings: $e',
      );
    }
  }

  // Get total score rankings for private tests in a class
  Future<List<Map<String, dynamic>>> getClassPrivateTestTotalScoreRankings(
    String classId,
  ) async {
    try {
      // Get the class document to access the students array
      final DocumentSnapshot classDoc =
          await _firestore.collection(_classCollection).doc(classId).get();

      if (!classDoc.exists) {
        throw Exception('Class not found');
      }

      final List<dynamic> studentIds =
          classDoc.get('students') as List<dynamic>;

      final QuerySnapshot result =
          await _firestore
              .collection(_studentAnswerForPrivateTestsCollection)
              .where('studentId', whereIn: studentIds)
              .get();

      // Group by studentId and calculate total scores
      final Map<String, double> studentTotalScores = {};
      final Map<String, int> studentTestCounts = {};

      for (var doc in result.docs) {
        final StudentAnswer answer = StudentAnswer.fromFirestore(doc);
        studentTotalScores[answer.studentId] =
            (studentTotalScores[answer.studentId] ?? 0) + answer.score;
        studentTestCounts[answer.studentId] =
            (studentTestCounts[answer.studentId] ?? 0) + 1;
      }

      // Calculate average scores and create ranking list
      final List<Map<String, dynamic>> rankings =
          studentTotalScores.entries.map((entry) {
            return {
              'studentId': entry.key,
              'totalScore': entry.value,
              'averageScore':
                  (entry.value / studentTestCounts[entry.key]!).toDouble(),
              'testCount': studentTestCounts[entry.key],
            };
          }).toList();

      // Sort by total score in descending order
      rankings.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));

      return rankings;
    } catch (e) {
      throw Exception(
        'Failed to get class private test total score rankings: $e',
      );
    }
  }

  // Get total wrong answers rankings for private tests in a class
  Future<List<Map<String, dynamic>>>
  getClassPrivateTestTotalWrongAnswersRankings(String classId) async {
    try {
      // Get the class document to access the students array
      final DocumentSnapshot classDoc =
          await _firestore.collection(_classCollection).doc(classId).get();

      if (!classDoc.exists) {
        throw Exception('Class not found');
      }

      final List<dynamic> studentIds =
          classDoc.get('students') as List<dynamic>;

      final QuerySnapshot result =
          await _firestore
              .collection(_studentAnswerForPrivateTestsCollection)
              .where('studentId', whereIn: studentIds)
              .get();

      // Group by studentId and calculate total wrong answers
      final Map<String, int> studentTotalWrongAnswers = {};
      final Map<String, int> studentTestCounts = {};

      for (var doc in result.docs) {
        final StudentAnswer answer = StudentAnswer.fromFirestore(doc);
        studentTotalWrongAnswers[answer.studentId] =
            (studentTotalWrongAnswers[answer.studentId] ?? 0) +
            answer.numOfWrongAnswers;
        studentTestCounts[answer.studentId] =
            (studentTestCounts[answer.studentId] ?? 0) + 1;
      }

      // Create ranking list
      final List<Map<String, dynamic>> rankings =
          studentTotalWrongAnswers.entries.map((entry) {
            return {
              'studentId': entry.key,
              'totalWrongAnswers': entry.value,
              'averageWrongAnswers':
                  (entry.value / studentTestCounts[entry.key]!).toDouble(),
              'testCount': studentTestCounts[entry.key],
            };
          }).toList();

      // Sort by total wrong answers in ascending order (fewer wrong answers is better)
      rankings.sort(
        (a, b) => a['totalWrongAnswers'].compareTo(b['totalWrongAnswers']),
      );

      return rankings;
    } catch (e) {
      throw Exception(
        'Failed to get class private test total wrong answers rankings: $e',
      );
    }
  }
}
