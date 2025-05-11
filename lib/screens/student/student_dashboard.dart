import 'package:flutter/material.dart';
import 'package:kid_arena/screens/student/class/assigned_tests_screen.dart';
import 'package:kid_arena/screens/student/leaderboard_screen.dart';
import 'package:kid_arena/screens/student/class/my_classes_screen.dart';
import 'package:kid_arena/screens/student/practice/public_tests_screen.dart';
import 'package:kid_arena/screens/student/personal/student_profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  final int index;

  const StudentDashboard({super.key, required this.index});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  final List<Widget> _pages = const [
    PublicTestsScreen(),
    AssignedTestsScreen(),
    MyClassesScreen(),
    LeaderboardScreen(),
    StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Tự luyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Bài kiểm tra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Lớp học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Bảng xếp hạng',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(160),
        backgroundColor: Theme.of(context).colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
