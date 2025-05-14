import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/blocs/theme/theme_bloc.dart';
import 'package:kid_arena/blocs/theme/theme_event.dart';
import 'package:kid_arena/blocs/theme/theme_state.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/student/class/my_notification.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/index.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Subject _selectedSubject = Subject.english;
  final RankingService _rankingService = getIt<RankingService>();
  final StudentService _studentService = getIt<StudentService>();
  List<Map<String, dynamic>> _rankings = [];
  Map<String, String> _studentNames = {};
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  int? _currentUserRank;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rankings = await _rankingService.getPublicTestTotalScoreRankings(
        _selectedSubject,
      );

      // Add sample data if there's not enough real data
      if (rankings.length < 10) {
        final sampleData = _generateSampleData(rankings.length);
        rankings.addAll(sampleData);
        rankings.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));
      }

      // Get student names
      final List<String> studentIds =
          rankings
              .where((r) => !r['studentId'].toString().startsWith('Student'))
              .map((r) => r['studentId'] as String)
              .toList();

      if (studentIds.isNotEmpty) {
        _studentNames = await _studentService.getStudentNames(studentIds);
      }

      // Find current user's rank
      if (_currentUserId != null) {
        _currentUserRank = rankings.indexWhere(
          (r) => r['studentId'] == _currentUserId,
        );
        if (_currentUserRank != -1) {
          _currentUserRank =
              (_currentUserRank ?? 0) + 1; // Convert to 1-based index
        }
      }

      setState(() {
        _rankings = rankings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStudentName(String studentId) {
    if (studentId.startsWith('Học sinh')) {
      final List<String> firstNames = [
        'Minh',
        'Anh',
        'Huy',
        'Nam',
        'Phương',
        'Linh',
        'Hà',
        'Ngọc',
        'Thảo',
        'Trang',
        'Tuấn',
        'Dũng',
        'Hùng',
        'Thắng',
        'Đức',
      ];

      // List of common Vietnamese last names
      final List<String> lastNames = [
        'Nguyễn',
        'Trần',
        'Lê',
        'Phạm',
        'Hoàng',
        'Huỳnh',
        'Phan',
        'Vũ',
        'Võ',
        'Đặng',
      ];
      int seed = _selectedSubject.hashCode + studentId.hashCode;
      return '${lastNames[Random(seed).nextInt(lastNames.length)]} ${firstNames[Random(seed).nextInt(firstNames.length)]}';
    }
    return _studentNames[studentId] ?? 'Unknown Student';
  }

  List<Map<String, dynamic>> _generateSampleData(int existingCount) {
    final List<Map<String, dynamic>> sampleData = [];
    final int neededCount = 12 - existingCount;

    for (int i = 0; i < neededCount; i++) {
      sampleData.add({
        'studentId': 'Học sinh ${existingCount + i + 1}',
        'totalScore': (85 - i * 2).toDouble(),
        'averageScore': ((85 - i * 2) / 3).toDouble(),
        'testCount': 3,
      });
    }

    return sampleData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text(
                  'Bảng xếp hạng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                floating: true,
                pinned: true,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideTransition(
                          MyNotification(
                            notificationFuture:
                                getIt<NotificationService>()
                                    .getNotificationsForStudent(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildSubjectSelector(),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      else if (_rankings.isEmpty)
                        const Center(child: Text('Chưa có dữ liệu xếp hạng'))
                      else ...[
                        _buildTopThree(),
                        const SizedBox(height: 24),
                        _buildLeaderboardList(),
                        // Add padding at bottom if user is not in top 10
                        if (_currentUserId != null &&
                            _currentUserRank != null &&
                            _currentUserRank! > 10)
                          const SizedBox(height: 100), // Space for pinned item
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Pinned user rank at bottom
          if (_currentUserId != null &&
              _currentUserRank != null &&
              _currentUserRank! > 10)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _buildPinnedLeaderboardItem(
                      _currentUserRank!,
                      _getStudentName(_currentUserId!),
                      _rankings
                          .firstWhere(
                            (r) => r['studentId'] == _currentUserId,
                            orElse: () => {'totalScore': 0},
                          )['totalScore']
                          .toInt(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<Subject>(
        value: _selectedSubject,
        isExpanded: true,
        underline: const SizedBox(),
        items:
            Subject.values.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject.name.toUpperCase()),
              );
            }).toList(),
        onChanged: (Subject? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedSubject = newValue;
            });
            _loadRankings();
          }
        },
      ),
    );
  }

  Widget _buildTopThree() {
    if (_rankings.length < 3) {
      return const SizedBox(
        child: Text(
          'Chưa đủ dữ liệu xếp hạng',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTopThreeItem(
          '2nd',
          _getStudentName(_rankings[1]['studentId']),
          _rankings[1]['totalScore'].toInt(),
          Colors.grey[400]!,
          const Offset(0, 0),
        ),
        _buildTopThreeItem(
          '1st',
          _getStudentName(_rankings[0]['studentId']),
          _rankings[0]['totalScore'].toInt(),
          Colors.amber,
          const Offset(0, -20),
        ),
        _buildTopThreeItem(
          '3rd',
          _getStudentName(_rankings[2]['studentId']),
          _rankings[2]['totalScore'].toInt(),
          Colors.orange[500]!,
          const Offset(0, 0),
        ),
      ],
    );
  }

  Widget _buildTopThreeItem(
    String rank,
    String name,
    int score,
    Color color,
    Offset offset,
  ) {
    return Transform.translate(
      offset: offset,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$score điểm',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Column(
      children: List.generate(
        _rankings.length > 3 ? (min(7, _rankings.length - 3)) : 0,
        (index) => _buildLeaderboardItem(
          index + 4,
          _getStudentName(_rankings[index + 3]['studentId']),
          _rankings[index + 3]['totalScore'].toInt(),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, int score) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedLeaderboardItem(int rank, String name, int score) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
