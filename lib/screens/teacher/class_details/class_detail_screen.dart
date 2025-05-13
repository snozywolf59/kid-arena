import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/screens/teacher/class_details/manage_test_in_class_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/manage_students_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/manage_notification.dart';
import 'package:kid_arena/screens/teacher/class_details/ranking.dart';

class ClassDetailScreen extends StatefulWidget {
  final Class classroom;

  const ClassDetailScreen({super.key, required this.classroom});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Học sinh'),
            Tab(text: 'Bài thi'),
            Tab(text: 'Thông báo'),
            Tab(text: 'BXH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ManageStudentsScreen(classroom: widget.classroom),
          ManageTestInClassScreen(classroom: widget.classroom),
          NotificationManage(classroom: widget.classroom),
          Ranking(classroom: widget.classroom),
        ],
      ),
    );
  }
}
