
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/constants/index.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/screens/student/quiz/quiz_screen.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/student/test/public_test_card.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/utils/page_transitions.dart';



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
  final TextEditingController _searchController = TextEditingController();
  List<PublicTest> _filteredUncompletedTests = [];
  List<PublicTest> _filteredCompletedTests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _searchController.addListener(_filterTests);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterTests() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredUncompletedTests =
          _getUncompletedTests()
              .where(
                (test) =>
                    test.title.toLowerCase().contains(searchQuery) ||
                    test.description.toLowerCase().contains(searchQuery),
              )
              .toList();

      _filteredCompletedTests =
          _getCompletedTests()
              .where(
                (test) =>
                    test.title.toLowerCase().contains(searchQuery) ||
                    test.description.toLowerCase().contains(searchQuery),
              )
              .toList();
    });
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
        _filteredUncompletedTests = _getUncompletedTests();
        _filteredCompletedTests = _getCompletedTests();
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _header(context),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _startlearning(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverAppBar(
              shadowColor: Theme.of(context).colorScheme.primary,
              elevation: 0,

              automaticallyImplyLeading: false,
              pinned: true,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Tìm kiếm bài thi...',
                  onSearch: (query) {
                    setState(() {});
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Chưa làm'),
                    Tab(text: 'Đã hoàn thành'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
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

  SliverToBoxAdapter _startlearning() {
    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }

  SliverAppBar _header(BuildContext context) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              widget.subject.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedTests() {
    if (_filteredCompletedTests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'Bạn chưa hoàn thành\nbài thi nào!'
                    : 'Không tìm thấy bài thi\nphù hợp với từ khóa!',
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
            if (_searchController.text.isEmpty)
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
      itemCount: _filteredCompletedTests.length,
      itemBuilder: (context, index) {
        final exam = _filteredCompletedTests[index];
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
    if (_filteredUncompletedTests.isEmpty) {
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
                _searchController.text.isEmpty
                    ? Icons.emoji_events_rounded
                    : Icons.search_off_rounded,
                size: 80,
                color:
                    _searchController.text.isEmpty
                        ? Colors.amber[700]
                        : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty
                  ? 'Chúc mừng bạn! 🎉'
                  : 'Không tìm thấy bài thi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    _searchController.text.isEmpty
                        ? Colors.amber[700]
                        : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _searchController.text.isEmpty
                    ? 'Bạn đã hoàn thành tất cả các bài thi của môn ${widget.subject.name}! Hãy tiếp tục phát huy nhé!'
                    : 'Không có bài thi nào phù hợp với từ khóa "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            if (_searchController.text.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
      itemCount: _filteredUncompletedTests.length,
      itemBuilder: (context, index) {
        final exam = _filteredUncompletedTests[index];
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
