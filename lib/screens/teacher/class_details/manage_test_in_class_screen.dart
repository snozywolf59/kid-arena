import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kid_arena/constants/index.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/teacher/test/create_test_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/test_completion_status_screen.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/common/custom_snackbar.dart';
import 'package:kid_arena/models/student_answer.dart';

class ManageTestInClassScreen extends StatefulWidget {
  final Class classroom;

  const ManageTestInClassScreen({super.key, required this.classroom});

  @override
  State<ManageTestInClassScreen> createState() =>
      _ManageTestInClassScreenState();
}

class _ManageTestInClassScreenState extends State<ManageTestInClassScreen> {
  bool _isLoading = false;
  List<PrivateTest> _tests = [];
  List<PrivateTest> _filteredTests = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<StudentAnswer>> _testAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTests(String query) {
    setState(() {
      _filteredTests =
          _tests.where((test) {
            return test.title.toLowerCase().contains(query.toLowerCase()) ||
                test.description.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tests = await getIt<TestService>().getTestsForClass(
        widget.classroom.id,
      );

      // Load student answers for each test
      final testAnswers = <String, List<StudentAnswer>>{};
      for (final test in tests) {
        final answers = await getIt<TestService>()
            .getStudentAnswersForAssignedTest(test.id);
        testAnswers[test.id] = answers;
      }

      setState(() {
        _tests = tests;
        _filteredTests = tests;
        _testAnswers = testAnswers;
      });
    } catch (e) {
      log('Lỗi khi tải dữ liệu bài thi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTestStatus(PrivateTest test) {
    final answers = _testAnswers[test.id] ?? [];
    if (answers.isEmpty) {
      return 'Chưa có học sinh làm bài';
    }

    final totalStudents = widget.classroom.students.length;
    final completedCount = answers.length;
    final averageScore =
        answers.fold(0.0, (sum, answer) => sum + answer.score) / completedCount;

    return 'Đã làm: $completedCount/$totalStudents học sinh\nĐiểm trung bình: ${(averageScore * 10).toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            PageTransitions.slideTransition(
              CreateTestScreen(classId: widget.classroom.id),
            ),
          );

          if (result == true) {
            await _loadData();
          }
        },
        label: const Text('Tạo bài thi'),
        icon: const Icon(Icons.add_box_rounded),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBarWidget(
                controller: _searchController,
                onSearch: _filterTests,
                hintText: 'Tìm kiếm bài thi...',
              ),
            ),
            if (_filteredTests.isEmpty)
              const Expanded(
                child: Center(child: Text('Không tìm thấy bài thi nào')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredTests.length,
                  itemBuilder: (context, index) {
                    final test = _filteredTests[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onTertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(Subject.getIcon(test.subject)),
                        title: Text(
                          test.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTestStatus(test),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              color: Theme.of(context).colorScheme.primary,
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransitions.slideTransition(
                                    TestCompletionStatusScreen(
                                      test: test,
                                      classroom: widget.classroom,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final shouldDelete = await ConfirmationDialog.show(
                                  context: context,
                                  title: 'Xác nhận xóa',
                                  message:
                                      'Bạn có chắc chắn muốn xóa bài thi ${test.title}?',
                                  confirmText: 'Xóa',
                                  isDestructive: true,
                                );

                                if (shouldDelete == true) {
                                  try {
                                    await getIt<TestService>().deleteTest(
                                      test.id,
                                    );
                                    await _loadData();
                                    if (context.mounted) {
                                      CustomSnackBar.showSuccess(
                                        context,
                                        'Đã xóa bài thi thành công',
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      CustomSnackBar.showError(
                                        context,
                                        'Lỗi khi xóa bài thi: $e',
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
