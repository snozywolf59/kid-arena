import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kid_arena/constants/image.dart';
import 'package:kid_arena/models/user/index.dart';
import 'package:kid_arena/screens/auth/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/screens/student/student_dashboard.dart';

import 'package:kid_arena/screens/teacher/teacher_dashboard.dart';
import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/common/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final User user = await getIt<AuthService>().login(
          _usernameController.text.toString(),
          _passwordController.text.toString(),
        );

        // Lấy thông tin role của user từ Firestore
        final AppUser appUser = await getIt<AuthService>().getUserData(
          user.uid,
        );
        log('${user.uid} logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );

          // Chuyển hướng dựa trên role
          if (appUser is StudentUser) {
            Navigator.pushAndRemoveUntil(
              context,
              PageTransitions.slideTransition(const StudentDashboard(index: 0)),
              (_) => false,
            );
          } else if (appUser is TeacherUser) {
            Navigator.pushAndRemoveUntil(
              context,
              PageTransitions.slideTransition(const TeacherHomePage()),
              (_) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Đã xảy ra lỗi';
        if (e.code == 'user-not-found') {
          message = 'Không tìm thấy tài khoản';
        } else if (e.code == 'wrong-password') {
          message = 'Mật khẩu không đúng';
        } else if (e.code == 'invalid-email') {
          message = 'Tên đăng nhập không hợp lệ';
        }
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi không xác định: ${e.toString()}'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    ImageLink.logoImage,
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: const Text('ĐĂNG NHẬP'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransitions.slideTransition(
                            const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Đăng ký ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
