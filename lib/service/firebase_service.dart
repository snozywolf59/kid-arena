import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AuthService {
  login(String username, String password);
  register(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
  );
  getUserData(String uid);
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
      print("Login error: $e");
      return null;
    }
  }

  // Đăng ký
  @override
  Future<User?> register(
    String fullName,
    String username,
    String password,
    String gender,
    String role,
    String? dateOfBirth,
  ) async {
    try {
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
      print("Register error: $e");
      return null;
    }
  }

  // Lấy thông tin người dùng
  @override
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Thêm các hàm khác cho chức năng thi cử...
}
