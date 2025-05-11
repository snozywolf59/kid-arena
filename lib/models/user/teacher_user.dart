import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/user/user.dart';

class TeacherUser extends AppUser {
  TeacherUser({
    required super.id,
    required super.fullName,
    required super.gender,
    required super.role,
    required super.username,
    required super.email,
    required super.createdAt,
    required super.dateOfBirth,
  });

  factory TeacherUser.fromFirebase(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TeacherUser(
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

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
    };
  }
}
