import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/question.dart';

class PublicTest {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String subject;
  final List<Question> questions;
  final DateTime createdAt;

  PublicTest({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.subject,
    required this.questions,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'subject': subject,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory PublicTest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PublicTest(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      subject: data['subject'] ?? '',
      questions: (data['questions'] as List?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
