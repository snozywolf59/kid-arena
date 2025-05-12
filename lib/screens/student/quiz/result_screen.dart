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
    int totalQuestions = test.questions.length;
    int correctAnswers = (studentAnswer.score / 100 * totalQuestions).round();
    String achievementMessage;
    Color scoreColor = theme.primaryColor;
    IconData achievementIcon = Icons.emoji_events_rounded;

    if (studentAnswer.score >= 85) {
      achievementMessage = "Xuất sắc! Bạn là một Bậc thầy Quiz!";
      scoreColor = Colors.green.shade600;
      achievementIcon = Icons.military_tech_rounded;
    } else if (studentAnswer.score >= 70) {
      achievementMessage = "Tuyệt vời! Làm rất tốt!";
      scoreColor = Colors.blue.shade600;
      achievementIcon = Icons.thumb_up_alt_rounded;
    } else if (studentAnswer.score >= 50) {
      achievementMessage = "Khá lắm! Tiếp tục cố gắng nhé!";
      scoreColor = Colors.deepOrangeAccent;
      achievementIcon = Icons.auto_awesome_rounded;
    } else {
      achievementMessage = "Cố gắng học thêm! Bạn sẽ làm được!";
      scoreColor = Colors.orange.shade700;
      achievementIcon = Icons.school_rounded;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scoreColor.withAlpha(51), // Màu nhạt hơn ở trên
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 1.0], // Điều chỉnh điểm dừng gradient
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
                    ),
                  ),
                  Text(
                    test.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CircularPercentIndicator(
                    radius: 90.0, // Tăng kích thước
                    lineWidth: 15.0, // Tăng độ dày
                    animation: true,
                    animationDuration: 1500,
                    percent: studentAnswer.score / 100,
                    center: Text(
                      "${studentAnswer.score.toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40.0,
                        color: scoreColor,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: scoreColor,
                    backgroundColor: scoreColor.withAlpha(65),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    achievementMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scoreColor, // Sử dụng scoreColor cho thông điệp
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildResultStat(
                    theme,
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Trả lời đúng',
                    value: '$correctAnswers / $totalQuestions câu',
                    iconColor: Colors.green.shade600,
                  ),
                  const SizedBox(height: 12),
                  _buildResultStat(
                    theme,
                    icon: Icons.access_time_filled_rounded,
                    label: 'Thời gian làm bài',
                    value: _formatTimeTaken(studentAnswer.timeTaken),
                    iconColor: theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildResultStat(
                    theme,
                    icon: Icons.calendar_today_rounded,
                    label: 'Ngày nộp bài',
                    value:
                        "${studentAnswer.submittedAt.toLocal().day}/${studentAnswer.submittedAt.toLocal().month}/${studentAnswer.submittedAt.toLocal().year}",
                    iconColor: Colors.blueGrey.shade600,
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home_filled),
                    label: const Text('Về Trang Chủ'),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageTransitions.slideTransition(
                          const StudentDashboard(index: 0),
                        ), // Truyền lại data
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử Quiz Khác'),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageTransitions.slideTransition(
                          const StudentDashboard(index: 0),
                        ),
                        (route) => false,
                      );
                    },
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 6, // Tăng blur
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            // Bao Icon lại để có background
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            // Để text không bị overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
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
