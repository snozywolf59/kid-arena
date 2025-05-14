import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/notification.dart';
import 'package:kid_arena/models/test/private_test.dart';
import 'package:kid_arena/screens/student/class/my_notification.dart';
import 'package:kid_arena/screens/student/class/my_test.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/get_it.dart';

class MyClassDetailScreen extends StatefulWidget {
  final Class classData;

  const MyClassDetailScreen({super.key, required this.classData});

  @override
  State<MyClassDetailScreen> createState() => _MyClassDetailScreenState();
}

class _MyClassDetailScreenState extends State<MyClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ClassNotification>> _notificationsFuture;
  late Future<List<PrivateTest>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initFuture();
  }

  void _initFuture() {
    final notificationService = getIt<NotificationService>();
    final testService = getIt<TestService>();

    _notificationsFuture = notificationService
        .getNotificationsForStudentInAClass(widget.classData.id);
    _testsFuture = testService.getTestsForClass(widget.classData.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.classData.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [Tab(text: 'Bài thi'), Tab(text: 'Thông báo')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyTest(testFuture: _testsFuture),
          MyNotification(
            notificationFuture: _notificationsFuture,
            showAppbar: false,
          ),
        ],
      ),
    );
  }
}
