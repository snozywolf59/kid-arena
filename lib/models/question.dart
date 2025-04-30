class Question {
  final int correctAnswer;
  final List<String> options;
  final String questionText;

  const Question({
    required this.correctAnswer, 
    required this.options,
    required this.questionText,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      correctAnswer: map['correctAnswer'] ?? 0,
      options: List<String>.from(map['options'] ?? []),
      questionText: map['questionText'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'correctAnswer': correctAnswer,
      'options': options,
      'questionText': questionText,
    };
  }
}
