import 'package:flutter/material.dart';
import 'package:kid_arena/constants/subject.dart';
import 'package:kid_arena/models/test/private_test.dart';
import 'package:kid_arena/screens/teacher/test/create_test_screen.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/teacher/test/test_detail_screen.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final TestService _testService = getIt<TestService>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PrivateTest> _filterTests(List<PrivateTest> tests) {
    if (_searchQuery.isEmpty) return tests;
    return tests.where((test) {
      final title = test.title.toLowerCase();
      final description = test.description.toLowerCase();
      final subject = test.subject;
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          description.contains(query) ||
          subject.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Danh sách bài thi'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SearchBarWidget(
              controller: _searchController,
              onSearch: (value) => setState(() => _searchQuery = value),
              hintText: 'Tìm kiếm bài thi...',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PrivateTest>>(
              stream: _testService.getTestsForTeacher(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SelectableText('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tests = snapshot.data ?? [];
                final filteredTests = _filterTests(tests);

                if (filteredTests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Chưa có bài thi nào'
                              : 'Không tìm thấy bài thi phù hợp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTests.length,
                  itemBuilder: (context, index) {
                    final test = filteredTests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // TODO: Navigate to test details
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      test.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder:
                                        (context) => [
                                          PopupMenuItem(
                                            value: 'view',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.visibility,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Xem chi tiết'),
                                              ],
                                            ),
                                            onTap:
                                                () => Navigator.push(
                                                  context,
                                                  PageTransitions.slideTransition(
                                                    TestDetailScreen(
                                                      test: test,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 8),
                                                Text('Chỉnh sửa'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final shouldEdit =
                                            await ConfirmationDialog.show(
                                              context: context,
                                              title: 'Xác nhận chỉnh sửa',
                                              message:
                                                  'Bạn có chắc chắn muốn chỉnh sửa bài thi ${test.title}?',
                                              confirmText: 'Chỉnh sửa',
                                              isDestructive: false,
                                            );

                                        if (shouldEdit == true &&
                                            context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Tính năng đang được phát triển',
                                              ),
                                            ),
                                          );
                                        }
                                      } else if (value == 'delete') {
                                        final shouldDelete =
                                            await ConfirmationDialog.show(
                                              context: context,
                                              title: 'Xác nhận xóa',
                                              message:
                                                  'Bạn có chắc chắn muốn xóa bài thi này?',
                                              confirmText: 'Xóa',
                                              isDestructive: true,
                                            );

                                        if (shouldDelete == true) {
                                          try {
                                            await _testService.deleteTest(
                                              test.id,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã xóa bài thi thành công',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Lỗi khi xóa bài thi: $e',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                test.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    Icons.question_answer,
                                    '${test.questions.length} câu hỏi',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Icons.access_time,
                                    '${test.duration} phút',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    Subject.getIcon(test.subject),
                                    test.subject,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ngày tạo: ${test.createdAt.toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            PageTransitions.slideTransition(const CreateTestScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo bài thi'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
