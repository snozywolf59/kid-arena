import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/firebase_options.dart';
import 'package:kid_arena/models/question.dart';
import 'package:kid_arena/models/test/abstract_test.dart';

class PublicTest extends Test {
  final String subject;

  final int grade;

  PublicTest({
    required super.id,
    required super.title,
    required super.description,
    required super.duration,
    required this.subject,
    required super.questions,
    required super.createdAt,
    required this.grade,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'subject': subject,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt,
      'grade': grade,
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
      grade: data['grade'] ?? 0,
    );
  }
}

void main() async {
  final String title = 'Kiểm tra kiến thức Toán học cơ bản';
  final String description =
      'Bài kiểm tra giúp bạn ôn lại các kiến thức toán học cơ bản như cộng, trừ, nhân, chia và hình học.';
  final List<Question> questions = [
    Question(
      questionText: '2 cộng 3 bằng bao nhiêu?',
      correctAnswer: 1,
      options: ['4', '5', '6', '3'],
    ),
    Question(
      questionText: 'Số nào sau đây là số chẵn?',
      correctAnswer: 2,
      options: ['3', '5', '8', '7'],
    ),
    Question(
      questionText: 'Hình nào có 4 cạnh bằng nhau?',
      correctAnswer: 0,
      options: ['Hình vuông', 'Hình tròn', 'Hình tam giác', 'Hình chữ nhật'],
    ),
    Question(
      questionText: '10 trừ 6 bằng bao nhiêu?',
      correctAnswer: 3,
      options: ['3', '2', '5', '4'],
    ),
    Question(
      questionText: 'Số tiếp theo sau số 9 là gì?',
      correctAnswer: 1,
      options: ['9', '10', '11', '8'],
    ),
    Question(
      questionText: 'Kết quả của 4 nhân 2 là bao nhiêu?',
      correctAnswer: 0,
      options: ['8', '6', '10', '7'],
    ),
    Question(
      questionText: '12 chia cho 3 bằng bao nhiêu?',
      correctAnswer: 2,
      options: ['6', '5', '4', '3'],
    ),
    Question(
      questionText: 'Số nào nhỏ nhất trong các số sau: 5, 2, 8, 3?',
      correctAnswer: 1,
      options: ['3', '2', '5', '8'],
    ),
    Question(
      questionText: 'Hình nào không có cạnh?',
      correctAnswer: 0,
      options: ['Hình tròn', 'Hình vuông', 'Hình tam giác', 'Hình chữ nhật'],
    ),
    Question(
      questionText: '5 cộng 0 bằng bao nhiêu?',
      correctAnswer: 2,
      options: ['0', '10', '5', '1'],
    ),
  ];
  final Subject subject = Subject.mathematics;

  //create a function that will create a public test to firestore
  PublicTest test = PublicTest(
    id: '1',
    title: title,
    description: description,
    duration: 10,
    subject: subject.name,
    questions: questions,
    createdAt: DateTime.now(),
    grade: 2,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.instance.collection('public_tests').add(test.toMap());
}
