import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/services/study_streak_service.dart';
import 'package:kid_arena/services/test_service.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../widgets/student/test/option_widget.dart';
import '../../../widgets/confirmation_dialog.dart';
import 'result_screen.dart';
import '../../../models/student_answer.dart';

class QuizScreen extends StatefulWidget {
  final Test test;

  const QuizScreen({super.key, required this.test});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = [];
  int? _currentlySelectedOption;

  Timer? _timer;
  int _timeRemainingInSeconds = 0;

  late AnimationController _progressController;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List<int>.filled(widget.test.questions.length, -1);
    _timeRemainingInSeconds = widget.test.duration;
    _startTimer();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemainingInSeconds > 0) {
        if (mounted) {
          setState(() {
            _timeRemainingInSeconds--;
          });
        } else {
          timer.cancel();
        }
      } else {
        _timer?.cancel();
        if (mounted) {
          _submitQuiz();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _currentlySelectedOption = optionIndex;
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    _progressController.reset();
    _progressController.forward();
    if (_currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentlySelectedOption = _selectedAnswers[_currentQuestionIndex];
      });
    } else {
      _showSubmitConfirmationDialog();
    }
  }

  void _previousQuestion() {
    _progressController.reset();
    _progressController.forward(); // Or a reverse animation
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _currentlySelectedOption = _selectedAnswers[_currentQuestionIndex];
      });
    }
  }

  Future<void> _showSubmitConfirmationDialog() async {
    final shouldSubmit = await ConfirmationDialog.show(
      context: context,
      title: 'Nộp bài?',
      message: 'Bạn có chắc chắn muốn nộp bài thi này?',
      confirmText: 'Nộp bài',
      cancelText: 'Tiếp tục làm',
    );

    if (shouldSubmit == true) {
      _submitQuiz();
    }
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await ConfirmationDialog.show(
      context: context,
      title: 'Thoát Quiz?',
      message:
          'Tiến trình của bạn sẽ không được lưu. Bạn có chắc chắn muốn thoát?',
      confirmText: 'Thoát',
      cancelText: 'Ở lại',
      isDestructive: true,
    );

    if (shouldExit == true) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      isSubmitting = true;
    });
    _timer?.cancel();
    int correctAnswers = 0;
    for (int i = 0; i < widget.test.questions.length; i++) {
      if (_selectedAnswers[i] != -1 &&
          _selectedAnswers[i] == widget.test.questions[i].correctAnswer) {
        correctAnswers++;
      }
    }
    log('correctAnswers: $correctAnswers');
    double score =
        (correctAnswers.toDouble() / widget.test.questions.length) * 100;
    int timeTaken = widget.test.duration - _timeRemainingInSeconds;
    log('duration: ${widget.test.duration}');
    try {
      await getIt<TestService>().submitStudentAnswerForAPublicTest(
        widget.test.id,
        timeTaken,
        _selectedAnswers,
        score,
      );
      await getIt<StudyStreakService>().addStudyDay();
      final studentAnswer = StudentAnswer(
        id: 'ans_${DateTime.now().millisecondsSinceEpoch}',
        studentId: FirebaseAuth.instance.currentUser?.uid ?? '',
        answers: _selectedAnswers,
        testId: widget.test.id,
        submittedAt: DateTime.now(),
        timeTaken: timeTaken,
        score: score,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResultsScreen(
                  studentAnswer: studentAnswer,
                  test: widget.test,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi nộp bài: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = widget.test.questions[_currentQuestionIndex];
    final double progress =
        (_currentQuestionIndex + 1) / widget.test.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitConfirmationDialog(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0), // Mỏng hơn
          child: LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: Colors.grey.shade300,
            progressColor: theme.primaryColor,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
            animation: true,
            animateFromLastPercent: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${_currentQuestionIndex + 1}/${widget.test.questions.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _timeRemainingInSeconds < 30
                            ? Colors.red.withOpacity(0.1)
                            : theme.hintColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_sharp, // Icon khác biệt
                        size: 18,
                        color:
                            _timeRemainingInSeconds < 30
                                ? Colors.red.shade700
                                : theme.hintColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDuration(_timeRemainingInSeconds),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _timeRemainingInSeconds < 30
                                  ? Colors.red.shade700
                                  : theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- Question Text with Animation ---
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0), // Slide từ phải qua nhẹ
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _progressController,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: _progressController,
                child: Container(
                  padding: const EdgeInsets.all(20.0), // Tăng padding
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.0), // Bo tròn hơn
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8, // Tăng blur
                        offset: const Offset(0, 3), // Tăng offset
                      ),
                    ],
                  ),
                  child: Text(
                    currentQuestion.questionText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4, // Tăng line height
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return OptionWidget(
                    optionText: currentQuestion.options[index],
                    isSelected: _currentlySelectedOption == index,
                    onTap: () => _selectOption(index),
                    optionChar: String.fromCharCode(65 + index), // A, B, C...
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment:
                    _currentQuestionIndex > 0
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      label: const Text('Trước'),
                      onPressed: _previousQuestion,
                    ),
                  ElevatedButton.icon(
                    icon:
                        _currentQuestionIndex ==
                                widget.test.questions.length - 1
                            ? const SizedBox.shrink() // Không icon khi là submit
                            : const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                    label: Text(
                      _currentQuestionIndex == widget.test.questions.length - 1
                          ? 'Nộp bài'
                          : 'Tiếp theo',
                    ),
                    onPressed:
                        _currentlySelectedOption != null ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            _currentQuestionIndex ==
                                    widget.test.questions.length - 1
                                ? 30
                                : 24,
                        vertical: 14,
                      ),
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
}
