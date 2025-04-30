import 'package:flutter/material.dart';
import 'package:kid_arena/screens/teacher/class_list_screen.dart';
import 'package:kid_arena/screens/teacher/test_list_screen.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [ClassListScreen(), const TestListScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Lớp'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Bài thi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFF5722), // Deep Orange
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

class HomeTeacher extends StatelessWidget {
  const HomeTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const Text('home'));
  }
}
