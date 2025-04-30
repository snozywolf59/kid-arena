import 'package:flutter/material.dart';
import 'package:kid_arena/constants/image.dart';
import 'package:kid_arena/screens/login_screen.dart';
import 'package:kid_arena/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/screens/student/home_student.dart';
import 'package:kid_arena/screens/teacher/home_teacher.dart';
import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/services/getIt.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in
        String userRole = await getIt<AuthService>().getCurrentUserRole();
        if (mounted) {
          _navigateToHomeScreen(userRole);
        }
      } else {
        // User is signed out
        if (mounted) {
          // Stay on splash screen, showing login/register buttons
          setState(() {});
        }
      }
    });
  }

  void _navigateToHomeScreen(String role) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                role == 'student'
                    ? const StudentHomePage()
                    : const TeacherHomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF5722), // Deep Orange
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageLink.logoImage, width: 150, height: 150),
            const SizedBox(height: 20),
            const Text(
              'KID ARENA',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Học tập - Thi đua - Vui vẻ',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF5722),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Đăng nhập",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF5722),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Đăng ký",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
