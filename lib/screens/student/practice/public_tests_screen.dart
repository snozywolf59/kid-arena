import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/screens/student/quiz/quiz_screen.dart';
import 'package:kid_arena/widgets/student/home/leaderboard_widget.dart';
import 'package:kid_arena/widgets/student/home/search_bar_widget.dart';
import 'package:kid_arena/widgets/student/home/study_streak_widget.dart';
import 'package:kid_arena/widgets/student/test/subject_card.dart';
import 'package:kid_arena/widgets/student/test/public_test_card.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/student/header_widget.dart';

class PublicTestsScreen extends StatelessWidget {
  const PublicTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(floating: true, title: HeaderWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: SearchBarWidget()),
            const SliverToBoxAdapter(child: StudyStreakWidget()),
            const SliverToBoxAdapter(child: LeaderboardWidget()),
            SliverPadding(
              padding: const EdgeInsets.only(left: 24, top: 24),
              sliver: SliverToBoxAdapter(
                child: const Text(
                  'Chọn môn học',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return SubjectCard(
                    subject: Subject.values[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideTransition(
                          ExamsScreen(subject: Subject.values[index]),
                        ),
                      );
                    },
                  );
                }, childCount: Subject.values.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamsScreen extends StatefulWidget {
  final Subject subject;

  const ExamsScreen({super.key, required this.subject});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with SingleTickerProviderStateMixin {
  final TestService _testService = getIt<TestService>();
  List<PublicTest> _tests = [];
  List<StudentAnswer> _studentAnswers = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final studentId = FirebaseAuth.instance.currentUser?.uid;
      if (studentId == null) return;

      final tests = await getIt<TestService>().getPublicTestsBySubject(
        widget.subject,
      );
      final answers = await _testService.getStudentAnswersForPublicTests(
        studentId,
      );

      setState(() {
        _tests = tests;
        _studentAnswers = answers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  List<PublicTest> _getUncompletedTests() {
    final completedTestIds = _studentAnswers.map((a) => a.testId).toSet();
    return _tests.where((test) => !completedTestIds.contains(test.id)).toList();
  }

  List<PublicTest> _getCompletedTests() {
    final completedTestIds = _studentAnswers.map((a) => a.testId).toSet();
    return _tests.where((test) => completedTestIds.contains(test.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 16),
            _startlearning(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Chưa làm'), Tab(text: 'Đã hoàn thành')],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Uncompleted Tests
                  _uncompletedTests(),
                  // Tab 2: Completed Tests
                  _completedTests(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _startlearning() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.subject.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.subject.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bắt đầu học',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hãy chọn một bài thi để bắt đầu ôn tập',
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.subject.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _completedTests() {
    if (_getCompletedTests().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Bạn chưa hoàn thành\nbài thi nào!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.do_not_disturb,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              child: const Text(
                "Làm ngay nào!",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _getCompletedTests().length,
      itemBuilder: (context, index) {
        final exam = _getCompletedTests()[index];
        final studentAnswer = _studentAnswers.firstWhere(
          (answer) => answer.testId == exam.id,
          orElse:
              () => StudentAnswer(
                id: '',
                studentId: '',
                answers: [],
                testId: exam.id,
                submittedAt: DateTime.now(),
                timeTaken: 0,
              ),
        );
        return PublicTestCard(
          title: exam.title,
          description: exam.description,
          subject: widget.subject.name,
          duration: exam.duration,
          isCompleted: true,
          score: studentAnswer.score,
          timeTaken: studentAnswer.timeTaken,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xem lại bài thi: ${exam.title}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  Widget _uncompletedTests() {
    if (_getUncompletedTests().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chúc mừng bạn! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Bạn đã hoàn thành tất cả các bài thi của môn ${widget.subject.name}! Hãy tiếp tục phát huy nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.amber[600]!],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tiếp tục học tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _getUncompletedTests().length,
      itemBuilder: (context, index) {
        final exam = _getUncompletedTests()[index];
        return PublicTestCard(
          title: exam.title,
          description: exam.description,
          subject: widget.subject.name,
          duration: exam.duration,
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.slideTransition(QuizScreen(test: exam as Test)),
            );
          },
        );
      },
    );
  }
}
