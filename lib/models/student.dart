import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String fullName;
  final String username;
  final String dateOfBirth;
  final int grade;
  final String className;
  final String schoolName;
  Student({
    required this.id, 
    required this.fullName, 
    required this.username,
    required this.dateOfBirth,
    required this.grade,
    required this.className,
    required this.schoolName,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Student(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      username: data['username'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      grade: data['grade'] ?? 0,
      className: data['className'] ?? '',
      schoolName: data['schoolName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'dateOfBirth': dateOfBirth,
      'grade': grade,
      'className': className,
      'schoolName': schoolName,
    };
  }
}
