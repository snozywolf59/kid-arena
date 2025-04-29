import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/question.dart';

class Exam {
  final String title;
  final String description;
  final int duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<Question> questions;
  final String createdAt;
  final String teacherId;

  const Exam({
    required this.title,
    required this.description,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.questions,
    required this.createdAt,
    required this.teacherId,
  });

  factory Exam.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Exam(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      questions: (data['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      createdAt: data['createdAt'] ?? '',
      teacherId: data['teacherId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt,
      'teacherId': teacherId,
    };
  }
}
