import 'package:flutter/material.dart';
import 'package:kid_arena/constants/image.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/screens/auth/login_screen.dart';
import 'package:kid_arena/screens/auth/register_screen.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                // Logo with enhanced size and animation
                Center(
                  child: Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          ImageLink.logoImage,
                          width: size.width * 0.25,
                          height: size.width * 0.25,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // Enhanced title with gradient
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ).createShader(bounds),
                  child: Text(
                    'Chào mừng bạn!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vui lòng chọn cách bạn muốn tiếp tục',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.06),
                // Enhanced Login Button
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransitions.fadeTransition(const LoginScreen()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Enhanced Register Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransitions.fadeTransition(const RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
