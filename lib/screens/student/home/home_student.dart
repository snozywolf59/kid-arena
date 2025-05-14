import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kid_arena/blocs/theme/theme_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_event.dart';
import 'package:kid_arena/blocs/theme/theme_state.dart';
import 'package:kid_arena/constants/index.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/screens/student/class/my_notification.dart';
import 'package:kid_arena/screens/student/practice/public_tests_screen.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/index.dart';
import 'package:kid_arena/widgets/index.dart';
import 'package:kid_arena/widgets/student/header_widget.dart';
import 'package:kid_arena/widgets/student/home/leaderboard_widget.dart';
import 'package:kid_arena/widgets/student/home/study_streak_widget.dart';

class HomeStudent extends StatefulWidget {
  const HomeStudent({super.key});

  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  final TestService _testService = getIt<TestService>();
  late Future<List<PrivateTest>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _testsFuture = _testService.getTestsForStudent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<PrivateTest> _getOngoingTests(List<PrivateTest> tests) {
    final now = DateTime.now();
    return tests.where((test) {
      return test.startTime.isBefore(now) && test.endTime.isAfter(now);
    }).toList();
  }

  List<PrivateTest> _getUpcomingTests(List<PrivateTest> tests) {
    final now = DateTime.now();
    return tests.where((test) {
      return test.startTime.isAfter(now);
    }).toList();
  }

  String _getTimeLeft(DateTime endTime) {
    String dateEnd = DateFormat('dd/MM').format(endTime);
    return 'Hạn:\n$dateEnd';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final testDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (testDate == today) {
      return 'Hôm nay,\n${DateFormat('HH:mm').format(dateTime)}';
    } else if (testDate == tomorrow) {
      return 'Ngày mai,\n${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd/MM,\nHH:mm').format(dateTime);
    }
  }

  Widget _buildOngoingTests(BuildContext context, List<PrivateTest> tests) {
    final theme = Theme.of(context);
    final displayTests = tests.take(3).toList();
    final hasMoreTests = tests.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tests.isEmpty)
          Center(
            child: Text(
              'Không có bài kiểm tra nào đang diễn ra',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                ...displayTests.map((test) {
                  return Column(
                    children: [
                      _buildOngoingTestItem(
                        context,
                        test.title,
                        test.description,
                        _getTimeLeft(test.endTime),
                        theme.colorScheme.primary,
                      ),
                      if (test != displayTests.last)
                        Divider(color: theme.colorScheme.outlineVariant),
                    ],
                  );
                }),
                if (hasMoreTests)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to all ongoing tests screen
                        },
                        child: Text(
                          'Xem tất cả (${tests.length})',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOngoingTestItem(
    BuildContext context,
    String title,
    String description,
    String timeLeft,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.timer, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              timeLeft,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTests(BuildContext context, List<PrivateTest> tests) {
    final theme = Theme.of(context);
    final displayTests = tests.take(3).toList();
    final hasMoreTests = tests.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tests.isEmpty)
          Center(
            child: Text(
              'Không có bài kiểm tra nào sắp tới',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                ...displayTests.map((test) {
                  return Column(
                    children: [
                      _buildTestItem(
                        context,
                        test.title,
                        test.description,
                        _formatDateTime(test.startTime),
                        theme.colorScheme.primary,
                      ),
                      if (test != displayTests.last)
                        Divider(color: theme.colorScheme.outlineVariant),
                    ],
                  );
                }),
                if (hasMoreTests)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to all upcoming tests screen
                        },
                        child: Text(
                          'Xem tất cả (${tests.length})',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTestItem(
    BuildContext context,
    String title,
    String description,
    String time,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.quiz, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              title: const HeaderWidget(),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransitions.slideTransition(const MyNotification()),
                    );
                  },
                  icon: Icon(Icons.notifications),
                ),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: Icon(
                        state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ThemeToggled());
                      },
                    );
                  },
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(child: StudyStreakWidget()),
            SliverPadding(
              padding: const EdgeInsets.only(left: 24),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Bảng vinh danh',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverToBoxAdapter(child: LeaderboardWidget()),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<List<PrivateTest>>(
                  future: _testsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tests = snapshot.data!;
                    final ongoingTests = _getOngoingTests(tests);
                    final upcomingTests = _getUpcomingTests(tests);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bài kiểm tra đang diễn ra',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (tests.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.live_tv,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildOngoingTests(context, ongoingTests),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Text(
                              'Bài kiểm tra sắp tới',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildUpcomingTests(context, upcomingTests),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 24, top: 24),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Bắt đầu luyện tập',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
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
