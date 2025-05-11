import 'package:flutter/material.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/test/private_test.dart';
import 'package:kid_arena/screens/student/quiz/quiz_screen.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/common/loading_indicator.dart';
import 'package:kid_arena/widgets/index.dart';

class AssignedTestsScreen extends StatefulWidget {
  

  const AssignedTestsScreen({super.key});

  @override
  State<AssignedTestsScreen> createState() => _AssignedTestsScreenState();
}

class _AssignedTestsScreenState extends State<AssignedTestsScreen> {

  List<PrivateTest> tests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() {
      isLoading = true;
    });
    final tests = await getIt<TestService>().getTestsForStudent();
    setState(() {
      this.tests = tests;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text(
              'Bài kiểm tra',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            floating: true,
            automaticallyImplyLeading: false,
            
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final test = tests[index];
                final now = DateTime.now();
                final timeRemaining = test.endTime.difference(now);
                final isOverdue = timeRemaining.isNegative;

                String timeText;
                Color statusColor;

                if (isOverdue) {
                  timeText = 'Overdue';
                  statusColor = Colors.red;
                } else if (timeRemaining.inDays > 0) {
                  timeText = 'Due in ${timeRemaining.inDays} days';
                  statusColor = Colors.orange;
                } else if (timeRemaining.inHours > 0) {
                  timeText = 'Due in ${timeRemaining.inHours} hours';
                  statusColor = Colors.orange;
                } else {
                  timeText = 'Due in ${timeRemaining.inMinutes} minutes';
                  statusColor = Colors.red;
                }

                return PrivateTestCard(
                  title: test.title,
                  subject: test.subject,
                  teacherId: test.teacherId,
                  dueDate: timeText,
                  color: statusColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransitions.slideTransition(QuizScreen(test: test)),
                    );
                  },
                );
              }, childCount: tests.length),
            ),
          ),
        ],
      ),
    );
  }
}
