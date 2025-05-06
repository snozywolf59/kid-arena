import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAnswer {
  final String id;
  final String studentId;
  final List<int> answers;
  final String testId;
  final DateTime submittedAt;

  StudentAnswer({
    required this.id,
    required this.studentId,
    required this.answers,
    required this.testId,
    required this.submittedAt,
  });

  factory StudentAnswer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentAnswer(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      answers: List<int>.from(data['answers'] ?? []),
      testId: data['testId'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'answers': answers,
      'testId': testId,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  StudentAnswer copyWith({
    String? id,
    String? studentId,
    List<int>? answers,
    String? testId,
    DateTime? submittedAt,
  }) {
    return StudentAnswer(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      answers: answers ?? this.answers,
      testId: testId ?? this.testId,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
