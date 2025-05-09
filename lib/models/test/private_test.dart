import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/test/abstract_test.dart';

class PrivateTest extends Test {
  final DateTime startTime;
  final DateTime endTime;
  final String classId;

  final String teacherId;
  final String subject;
  const PrivateTest({
    required super.id,
    required super.title,
    required super.description,
    required super.duration,
    required super.questions,
    required this.startTime,
    required this.endTime,
    required this.classId,
    required this.teacherId,
    required this.subject,
    required super.createdAt,
  });

  factory PrivateTest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PrivateTest(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      classId: data['classId'],
      questions:
          (data['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teacherId: data['teacherId'] ?? '',
      subject: data['subject'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'classId': classId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'teacherId': teacherId,
      'subject': subject,
    };
  }
}
