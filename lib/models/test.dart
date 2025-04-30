import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/question.dart';

class Test {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final String teacherId;
  final DateTime createdAt;

  const Test({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.teacherId,
    required this.createdAt,
  });

  factory Test.fromMap(Map<String, dynamic> map) {
    return Test(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      teacherId: map['teacherId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'teacherId': teacherId,
      'createdAt': createdAt,
    };
  }
}
