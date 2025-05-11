import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/user.dart';

abstract class AuthService {
  login(String username, String password);
  registerTeacher(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
  );

  registerStudent(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
    int? grade,
    String? className,
    String? schoolName,
  );

  logout();
  getUserData(String uid);

  getCurrentUserData();

  getCurrentUserRole();
}

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng nhập
  @override
  Future<User?> login(String username, String password) async {
    try {
      // Trong thực tế cần query username trước để lấy email
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: "$username@kidarena.com", // hoặc lưu email trong Firestore
        password: password,
      );
      return credential.user;
    } catch (e) {
      log("Login error: $e");
      return null;
    }
  }

  // Đăng ký
  @override
  Future<User?> registerTeacher(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
  ) async {
    try {
      if (role != 'teacher') throw Exception('Not a teacher');
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: "$username@kidarena.com",
        password: password,
      );

      // Lưu thông tin người dùng vào Firestore

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'fullName': fullName,
        'username': username,
        'gender': gender,
        'role': role,
        'dateOfBirth': dateOfBirth,
        'createdAt': FieldValue.serverTimestamp(),
        'email': "$username@kidarena.com",
      });
      return credential.user;
    } catch (e) {
      log("Register error: $e");
      return null;
    }
  }

  @override
  void logout() {
    _auth.signOut();
  }

  @override
  Future<AppUser> getUserData(String uid) async {
    DocumentSnapshot user = await _firestore.collection('users').doc(uid).get();
    Map<String, dynamic> data = user.data() as Map<String, dynamic>;
    if (data['role'] == 'student') {
      return StudentUser.fromFirebase(user);
    }
    return AppUser.fromFirebase(user);
  }

  @override
  Future<AppUser> getCurrentUserData() async {
    var currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw FirebaseAuthException(code: '200');
    }
    return getUserData(currentUserId);
  }

  @override
  Future<String> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        return userData.get('role') as String;
      }
      return '';
    } catch (e) {
      log("Error getting user role: $e");
      return '';
    }
  }

  @override
  Future<User?> registerStudent(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
    int? grade,
    String? className,
    String? schoolName,
  ) async {
    try {
      if (role != 'student') throw Exception('Not a student');
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: "$username@kidarena.com",
        password: password,
      );

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'fullName': fullName,
        'username': username,
        'gender': gender,
        'role': role,
        'dateOfBirth': dateOfBirth,
        'grade': grade,
        'className': className,
        'schoolName': schoolName,
        'createdAt': FieldValue.serverTimestamp(),
        'email': "$username@kidarena.com",
      });
      return credential.user;
    } catch (e) {
      log("Register error: $e");
      return null;
    }
  }
}
