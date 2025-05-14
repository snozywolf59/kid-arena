import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/user_service.dart';
import 'package:kid_arena/constants/index.dart';

class TestCompletionStatusScreen extends StatefulWidget {
  final PrivateTest test;
  final Class classroom;

  const TestCompletionStatusScreen({
    super.key,
    required this.test,
    required this.classroom,
  });

  @override
  State<TestCompletionStatusScreen> createState() =>
      _TestCompletionStatusScreenState();
}

class _TestCompletionStatusScreenState
    extends State<TestCompletionStatusScreen> {
  bool _isLoading = true;
  List<StudentAnswer> _studentAnswers = [];
  Map<String, String> _studentNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load student answers
      final answers = await getIt<TestService>()
          .getStudentAnswersForAssignedTest(widget.test.id);

      // Load student names
      final studentNames = <String, String>{};
      for (final studentId in widget.classroom.students) {
        final user = await getIt<UserService>().getUserById(studentId);
        if (user != null) {
          studentNames[studentId] = user.fullName;
        }
      }

      setState(() {
        _studentAnswers = answers;
        _studentNames = studentNames;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStudentCard(String studentId) {
    final studentName = _studentNames[studentId] ?? 'Unknown Student';
    final studentAnswer = _studentAnswers.firstWhere(
      (answer) => answer.studentId == studentId,
      orElse:
          () => StudentAnswer(
            id: '',
            studentId: studentId,
            answers: [],
            testId: widget.test.id,
            submittedAt: DateTime.now(),
            timeTaken: 0,
            score: 0,
            numOfWrongAnswers: 0,
          ),
    );

    final hasCompleted = studentAnswer.id.isNotEmpty;
    final score = studentAnswer.score * 10; // Convert to 10-point scale

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                studentName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasCompleted) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đã hoàn thành',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Thời gian: ${studentAnswer.timeTaken ~/ 60} phút ${studentAnswer.timeTaken % 60} giây',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Chưa làm bài',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${score.toStringAsFixed(1)} điểm',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Color _getScoreColor(double score) {
    if (score >= 8) {
      return Theme.of(context).colorScheme.primary;
    } else if (score >= 6.5) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Subject.getIcon(widget.test.subject),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng quan',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đã hoàn thành: ${_studentAnswers.length}/${widget.classroom.students.length} học sinh',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.classroom.students.length,
                itemBuilder: (context, index) {
                  return _buildStudentCard(widget.classroom.students[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
