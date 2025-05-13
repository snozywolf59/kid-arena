// Dart packages

// Flutter packages
import 'package:flutter/material.dart';

// Pub packages

// Project packages
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/test/private_test.dart';
import 'package:kid_arena/screens/student/quiz/quiz_screen.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/common/loading_indicator.dart';
import 'package:kid_arena/widgets/index.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';

class AssignedTestsScreen extends StatefulWidget {
  const AssignedTestsScreen({super.key});

  @override
  State<AssignedTestsScreen> createState() => _AssignedTestsScreenState();
}

class _AssignedTestsScreenState extends State<AssignedTestsScreen>
    with SingleTickerProviderStateMixin {
  List<PrivateTest> _tests = [];
  List<StudentAnswer> _studentAnswers = [];
  bool isLoading = false;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, String> _classNameCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTests() async {
    setState(() {
      isLoading = true;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final tests = await getIt<TestService>().getTestsForStudent();
      final answers = await getIt<TestService>()
          .getStudentAnswersForPublicTests(currentUser.uid);

      // Load class names for all tests
      for (final test in tests) {
        if (!_classNameCache.containsKey(test.classId)) {
          final className = await _getClassName(test.classId);
          _classNameCache[test.classId] = className;
        }
      }

      setState(() {
        _tests = tests;
        _studentAnswers = answers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
      }
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
          ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<PrivateTest> _getFilteredTests(int tabIndex) {
    final now = DateTime.now();
    List<PrivateTest> filteredTests;

    switch (tabIndex) {
      case 0: // Scheduled tests
        filteredTests =
            _tests.where((test) {
              final timeRemaining = test.endTime.difference(now);
              return !timeRemaining.isNegative && timeRemaining.inDays <= 0;
            }).toList();
        break;
      case 1: // Ongoing tests
        filteredTests =
            _tests.where((test) {
              final timeRemaining = test.endTime.difference(now);
              return !timeRemaining.isNegative && timeRemaining.inDays > 0;
            }).toList();
        break;
      case 2: // Overdue tests
        filteredTests =
            _tests.where((test) {
              final timeRemaining = test.endTime.difference(now);
              return timeRemaining.isNegative;
            }).toList();
        break;
      default:
        filteredTests = [];
    }

    if (_searchQuery.isNotEmpty) {
      filteredTests =
          filteredTests.where((test) {
            return test.title.toLowerCase().contains(_searchQuery) ||
                test.subject.toLowerCase().contains(_searchQuery);
          }).toList();
    }

    return filteredTests;
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
    final timeRemaining = test.endTime.difference(now);

    if (timeRemaining.isNegative) {
      return Colors.red;
    } else if (timeRemaining.inDays > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                'Bài kiểm tra',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchBarWidget(
                              controller: _searchController,
                              onSearch: _onSearch,
                              hintText: 'Tìm kiếm bài thi...',
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Đang diễn ra'),
                        Tab(text: 'Sắp tới'),
                        Tab(text: 'Quá hạn'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: List.generate(3, (index) {
            final filteredTests = _getFilteredTests(index);
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final test = filteredTests[index];
                      final isCompleted = _isTestCompleted(test.id);
                      final studentAnswer =
                          isCompleted ? _getTestAnswer(test.id) : null;

                      return PrivateTestCard(
                        title: test.title,
                        subject: test.subject,
                        className:
                            _classNameCache[test.classId] ?? 'Đang tải...',
                        dueDate: _getTimeText(test),
                        color: _getStatusColor(test),
                        isCompleted: isCompleted,
                        score: studentAnswer?.score,
                        timeTaken: studentAnswer?.timeTaken,
                        onTap: () {
                          if (isCompleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Xem lại bài thi: ${test.title}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              PageTransitions.slideTransition(
                                QuizScreen(test: test),
                              ),
                            );
                          }
                        },
                      );
                    }, childCount: filteredTests.length),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Future<String> _getClassName(String classId) async {
  final classService = getIt<ClassService>();
  final classData = await classService.getClassById(classId);
  return classData?.name ?? '';
}
