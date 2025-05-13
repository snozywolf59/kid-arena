// Dart packages

// Flutter packages
import 'package:flutter/material.dart';

// Pub packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/constants/image.dart';

// Project packages
import 'package:kid_arena/models/user/index.dart';
import 'package:kid_arena/screens/auth/auth_selection_screen.dart';
import 'package:kid_arena/screens/student/student_dashboard.dart';
import 'package:kid_arena/screens/teacher/teacher_dashboard.dart';
import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/utils/page_transitions.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Logo Section
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              ImageLink.logoImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          // Welcome Header
                          Text(
                            'Chào mừng đến với\nKid Arena!',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nơi học tập thú vị và hiệu quả',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Feature Cards
                    _buildFeatureCard(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Học tập',
                      description: 'Khám phá các bài học thú vị',
                      color: colorScheme.primaryContainer,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context,
                      icon: Icons.quiz_rounded,
                      title: 'Kiểm tra',
                      description: 'Luyện tập với các bài quiz',
                      color: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Xếp hạng',
                      description: 'Theo dõi thành tích của bạn',
                      color: colorScheme.tertiaryContainer,
                    ),
                    const Spacer(),
                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          _toNextScreen(context);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Bắt đầu ngay',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toNextScreen(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser != null) {
      AppUser user = await getIt<AuthService>().getUserData(
        FirebaseAuth.instance.currentUser!.uid,
      );

      if (!context.mounted) return;

      if (user is StudentUser) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransitions.slideTransition(const StudentDashboard(index: 0)),
          (route) => false,
        );
      } else if (user is TeacherUser) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransitions.slideTransition(const TeacherHomePage()),
          (route) => false,
        );
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransitions.slideTransition(const AuthSelectionScreen()),
        (route) => false,
      );
    }
  }
}
