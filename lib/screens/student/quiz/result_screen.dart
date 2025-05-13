import 'package:flutter/material.dart';
import 'package:kid_arena/models/student_answer.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kid_arena/screens/student/practice/public_tests_screen.dart';
import 'package:kid_arena/screens/student/student_dashboard.dart';
// import 'quiz_screen.dart'; // Để làm lại quiz (cần truyền lại test)

class ResultsScreen extends StatelessWidget {
  final StudentAnswer studentAnswer;
  final Test test;

  const ResultsScreen({
    super.key,
    required this.studentAnswer,
    required this.test,
  });

  String _formatTimeTaken(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    String result = "";
    if (minutes > 0) {
      result += "$minutes phút ";
    }
    result += "$seconds giây";
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int totalQuestions = test.questions.length;
    int correctAnswers = (studentAnswer.score / 100 * totalQuestions).round();
    String achievementMessage;
    Color scoreColor;
    IconData achievementIcon;

    if (studentAnswer.score >= 85) {
      achievementMessage = "Xuất sắc! Bạn là một Bậc thầy Quiz!";
      scoreColor = colorScheme.primary;
      achievementIcon = Icons.military_tech_rounded;
    } else if (studentAnswer.score >= 70) {
      achievementMessage = "Tuyệt vời! Làm rất tốt!";
      scoreColor = colorScheme.tertiary;
      achievementIcon = Icons.thumb_up_alt_rounded;
    } else if (studentAnswer.score >= 50) {
      achievementMessage = "Khá lắm! Tiếp tục cố gắng nhé!";
      scoreColor = colorScheme.secondary;
      achievementIcon = Icons.auto_awesome_rounded;
    } else {
      achievementMessage = "Cố gắng học thêm! Bạn sẽ làm được!";
      scoreColor = colorScheme.error;
      achievementIcon = Icons.school_rounded;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scoreColor.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(achievementIcon, size: 60, color: scoreColor),
                  const SizedBox(height: 16),
                  Text(
                    'Kết quả Quiz',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    test.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CircularPercentIndicator(
                    radius: 90.0,
                    lineWidth: 15.0,
                    animation: true,
                    animationDuration: 1500,
                    percent: studentAnswer.score / 100,
                    center: Text(
                      "${studentAnswer.score.toStringAsFixed(0)}%",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: scoreColor,
                    backgroundColor: scoreColor.withOpacity(0.2),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    achievementMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildResultStat(
                    theme,
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Trả lời đúng',
                    value: '$correctAnswers / $totalQuestions câu',
                    iconColor: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildResultStat(
                    theme,
                    icon: Icons.access_time_filled_rounded,
                    label: 'Thời gian làm bài',
                    value: _formatTimeTaken(studentAnswer.timeTaken),
                    iconColor: colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  _buildResultStat(
                    theme,
                    icon: Icons.calendar_today_rounded,
                    label: 'Ngày nộp bài',
                    value:
                        "${studentAnswer.submittedAt.toLocal().day}/${studentAnswer.submittedAt.toLocal().month}/${studentAnswer.submittedAt.toLocal().year}",
                    iconColor: colorScheme.tertiary,
                  ),

                  // (Optional) Review Answers Button
                  // TextButton.icon(
                  //   icon: Icon(Icons.rate_review_outlined, color: theme.primaryColor),
                  //   label: Text('Xem lại bài làm', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
                  //   onPressed: () {
                  //     // TODO: Navigate to a review screen
                  //   },
                  // ),
                  // const SizedBox(height: 10),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.home_filled, color: colorScheme.onPrimary),
                    label: Text(
                      'Về Trang Chủ',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageTransitions.slideTransition(
                          const StudentDashboard(index: 0),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      'Thử Quiz Khác',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageTransitions.slideTransition(
                          const StudentDashboard(index: 0),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
