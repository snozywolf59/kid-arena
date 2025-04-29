import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/question.dart';

class Test {
  final List<Question> questions;
  final String teacherId;
  final String title;
  final String description;
  final DateTime createdAt;
  const Test({
    required this.questions,
    required this.teacherId,
    required this.title, 
    required this.description,
    required this.createdAt,
  });

  factory Test.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Test(
      questions: (data['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      teacherId: data['teacherId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questions': questions.map((q) => q.toMap()).toList(),
      'teacherId': teacherId,
      'title': title,
      'description': description, 
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
