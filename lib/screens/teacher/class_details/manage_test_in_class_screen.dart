import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/teacher/test/create_test_screen.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';

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
      setState(() {
        _tests = tests;
        _filteredTests = tests;
      });
    } catch (e) {
      log('Lỗi khi tải dữ liệu bài thi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageTransitions.slideTransition(
              CreateTestScreen(classId: widget.classroom.id),
            ),
          );
        },
        label: const Text('Tạo bài thi'),
        icon: const Icon(Icons.add_box_rounded),
      ),
      body: Column(
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
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(test.title),
                      subtitle: Text(test.description),
                      trailing: IconButton(
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
                              await getIt<TestService>().deleteTest(test.id);
                              await _loadData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã xóa bài thi thành công'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi xóa bài thi: $e'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
