import 'package:flutter/material.dart';
import 'package:kid_arena/screens/student/assigned_tests_screen.dart';
import 'package:kid_arena/screens/student/leaderboard_screen.dart';
import 'package:kid_arena/screens/student/progress_screen.dart';
import 'package:kid_arena/screens/student/public_tests_screen.dart';
import 'package:kid_arena/screens/student/student_profile_screen.dart';

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
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.index;
  }

  final List<Widget> _pages = [
    const PublicTestsScreen(),
    const AssignedTestsScreen(),
    const LeaderboardScreen(),
    const ProgressScreen(),
    const StudentProfileScreen(),
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
            icon: Icon(Icons.quiz_outlined),
            label: 'Tự luyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Bài kiểm tra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Bảng xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
