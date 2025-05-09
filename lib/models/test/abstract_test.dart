import 'package:kid_arena/models/question.dart';


abstract class Test {
  final String id;
  final String title;
  final String description;
  final int duration;
  final List<Question> questions;
  final DateTime createdAt;

  const Test({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.questions,
    required this.createdAt,
  });
}

