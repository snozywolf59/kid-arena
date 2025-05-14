import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/screens/student/quiz/quiz_screen.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/index.dart';
import 'package:kid_arena/widgets/common/loading_indicator.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/index.dart';
import 'package:kid_arena/widgets/common/custom_snackbar.dart';

class MyTest extends StatefulWidget {
  final Future<List<PrivateTest>> testFuture;
  const MyTest({super.key, required this.testFuture});

  @override
  State<MyTest> createState() => _MyTestState();
}

class _MyTestState extends State<MyTest> {
  bool _isLoading = true;
  List<PrivateTest> _tests = [];
  List<StudentAnswer> _studentAnswers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      final tests = await widget.testFuture;
      final studentAnswers = await getIt<TestService>()
          .getStudentAnswersForAssignedTest(currentUser.uid);
      setState(() {
        _tests = tests;
        _studentAnswers = studentAnswers;
      });
      log('tests: $_tests');
    } catch (e) {
      CustomSnackBar.showError(context, 'Lỗi khi tải bài thi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isTestCompleted(String testId) {
    return _studentAnswers.any((answer) => answer.testId == testId);
  }

  StudentAnswer? _getTestAnswer(String testId) {
    return _studentAnswers.firstWhere(
      (answer) => answer.testId == testId,
      orElse:
          () => StudentAnswer(
            id: '',
            studentId: '',
            answers: [],
            testId: testId,
            submittedAt: DateTime.now(),
            timeTaken: 0,
            score: 0,
            numOfWrongAnswers: 0,
          ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  String _getTimeText(PrivateTest test) {
    final now = DateTime.now();
    final timeRemaining = test.endTime.difference(now);

    if (timeRemaining.isNegative) {
      return 'Đã quá hạn';
    } else if (timeRemaining.inDays > 0) {
      return 'Còn ${timeRemaining.inDays} ngày';
    } else if (timeRemaining.inHours > 0) {
      return 'Còn ${timeRemaining.inHours} giờ';
    } else {
      return 'Còn ${timeRemaining.inMinutes} phút';
    }
  }

  Color _getStatusColor(PrivateTest test) {
    if (_isTestCompleted(test.id)) {
      return Colors.green;
    }

    final now = DateTime.now();

    if (test.startTime.isAfter(now)) {
      return Colors.indigo;
    } else if (test.endTime.isBefore(now)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  List<PrivateTest> _getFilteredTests() {
    List<PrivateTest> filteredTests = [];

    if (_searchQuery.isNotEmpty) {
      filteredTests =
          _tests.where((test) {
            return test.title.toLowerCase().contains(_searchQuery) ||
                test.subject.toLowerCase().contains(_searchQuery);
          }).toList();
    } else {
      filteredTests = _tests;
    }
    return filteredTests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const LoadingIndicator() : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final filteredTests = _getFilteredTests();
    log('filteredTests: $filteredTests');
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWidget(
              controller: _searchController,
              onSearch: _onSearch,
              hintText: 'Tìm kiếm bài thi...',
            ),
          ),
          floating: true,
          pinned: true,
          automaticallyImplyLeading: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final test = filteredTests[index];
              final isCompleted = _isTestCompleted(test.id);
              final studentAnswer =
                  isCompleted ? _getTestAnswer(test.id) : null;
              log('studentAnswer: $studentAnswer');
              return PrivateTestCard(
                title: test.title,
                subject: test.subject,
                className: '',
                dueDate: _getTimeText(test),
                color: _getStatusColor(test),
                isCompleted: isCompleted,
                score: studentAnswer?.score,
                timeTaken: studentAnswer?.timeTaken,
                onTap: () {
                  if (isCompleted) {
                    CustomSnackBar.showSuccess(
                      context,
                      'Xem lại bài thi: ${test.title}',
                    );
                  } else {
                    Navigator.push(
                      context,
                      PageTransitions.slideTransition(QuizScreen(test: test)),
                    );
                  }
                },
              );
            }, childCount: filteredTests.length),
          ),
        ),
        SliverFillRemaining(),
      ],
    );
  }
}
