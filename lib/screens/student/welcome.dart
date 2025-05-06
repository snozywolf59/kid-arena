import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_event.dart';
import 'package:kid_arena/blocs/theme/theme_state.dart';
import 'package:kid_arena/screens/student/public_tests_screen.dart';
import 'package:kid_arena/screens/student/assigned_tests_screen.dart';
import 'package:kid_arena/screens/student/student_dashboard.dart';
import 'package:kid_arena/screens/student/test_history_screen.dart';
import 'package:kid_arena/screens/student/leaderboard_screen.dart';
import 'package:kid_arena/screens/student/progress_screen.dart';
import 'package:kid_arena/screens/student/my_classes_screen.dart';

class StudentWelcomeScreen extends StatelessWidget {
  const StudentWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              floating: true,
              title: const Text(
                'Kid Arena',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: Icon(
                        state.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ThemeToggled());
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    context,
                    'Practice Tests',
                    Icons.quiz_outlined,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentDashboard(index: 0),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Assigned Tests',
                    Icons.assignment_outlined,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentDashboard(index: 1),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Test History',
                    Icons.history_outlined,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentDashboard(index: 2),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Leaderboard',
                    Icons.leaderboard_outlined,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentDashboard(index: 3),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'My Progress',
                    Icons.trending_up_outlined,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentDashboard(index: 4),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'My Classes',
                    Icons.class_outlined,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyClassesScreen(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(200), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
