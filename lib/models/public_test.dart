import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/firebase_options.dart';
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
      questions:
          (data['questions'] as List?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}

void main() async {
  final String title = 'Kiểm tra tiếng Anh chào hỏi';
  final String description = 'Kiểm tra tiếng Anh chào hỏi của bạn';
  final List<Question> questions = [
    Question(
      questionText: 'How do you say hello in English?',
      correctAnswer: 0,
      options: ['Hello', 'Goodbye', 'Thanks', 'Please'],
    ),
    Question(
      questionText: 'What do you say when you leave?',
      correctAnswer: 3,
      options: ['Hi', 'Good morning', 'Thanks', 'Goodbye'],
    ),
    Question(
      questionText: 'How do you ask someone’s name?',
      correctAnswer: 1,
      options: [
        'How old are you?',
        'What is your name?',
        'Where are you from?',
        'How are you?',
      ],
    ),
    Question(
      questionText: 'What do you say when you receive a gift?',
      correctAnswer: 2,
      options: ['Sorry', 'Hello', 'Thank you', 'Good night'],
    ),
    Question(
      questionText: 'What do you say if you hurt someone by accident?',
      correctAnswer: 1,
      options: ['Thank you', 'Sorry', 'Yes', 'Hi'],
    ),
    Question(
      questionText: 'How do you greet someone in the morning?',
      correctAnswer: 0,
      options: ['Good morning', 'Good night', 'See you', 'Hello'],
    ),
    Question(
      questionText: 'How do you reply to "How are you?"',
      correctAnswer: 3,
      options: [
        'What is your name?',
        'Yes, I am.',
        'Goodbye!',
        'I’m fine, thank you.',
      ],
    ),
    Question(
      questionText: 'What do you say when asking for something?',
      correctAnswer: 2,
      options: ['Hello', 'Thanks', 'Please', 'Sorry'],
    ),
    Question(
      questionText: 'How do you say "Tạm biệt" in English?',
      correctAnswer: 1,
      options: ['Hello', 'Goodbye', 'Thank you', 'Nice to meet you'],
    ),
    Question(
      questionText: 'What do you say when meeting someone for the first time?',
      correctAnswer: 3,
      options: ['See you', 'Please', 'Sorry', 'Nice to meet you'],
    ),
  ];
  final Subject subject = Subject.english;

  //create a function that will create a public test to firestore
  PublicTest test = PublicTest(
    id: '1',
    title: title,
    description: description,
    duration: 5,
    subject: subject.name,
    questions: questions,
    createdAt: DateTime.now(),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.instance.collection('public_tests').add(test.toMap());
}
