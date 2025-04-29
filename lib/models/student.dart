import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String username;
  final String dateOfBirth;

  Student({
    required this.id, 
    required this.name, 
    required this.username,
    required this.dateOfBirth,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'dateOfBirth': dateOfBirth,
    };
  }
}
