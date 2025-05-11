import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String fullName;
  String gender;
  String role;
  String username;
  String email;
  DateTime createdAt;
  String dateOfBirth;

  AppUser({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.role,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.dateOfBirth,
  });

  factory AppUser.fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      fullName: data['fullName']?.toString().trim() ?? '',
      gender: data['gender']?.toString().trim() ?? '',
      role: data['role']?.toString().trim() ?? '',
      username: data['username']?.toString().trim() ?? '',
      email: data['email']?.toString().trim() ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dateOfBirth: data['dateOfBirth']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'gender': gender,
      'role': role,
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}


