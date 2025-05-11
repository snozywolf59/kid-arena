import 'package:flutter/material.dart';
import 'package:kid_arena/models/test/private_test.dart';
import 'package:kid_arena/screens/teacher/create_test_screen.dart';
import 'package:kid_arena/services/get_it.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final TestService _testService = getIt<TestService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách bài thi')),
      body: StreamBuilder<List<PrivateTest>>(
        stream: _testService.getTestsForTeacher(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tests = snapshot.data ?? [];

          if (tests.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có bài thi nào',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    test.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(test.description),
                      const SizedBox(height: 8),
                      Text(
                        'Số câu hỏi: ${test.questions.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Ngày tạo: ${test.createdAt.toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final shouldEdit = await ConfirmationDialog.show(
                          context: context,
                          title: 'Xác nhận chỉnh sửa',
                          message:
                              'Bạn có chắc chắn muốn chỉnh sửa bài thi ${test.title}?',
                          confirmText: 'Chỉnh sửa',
                          isDestructive: false,
                        );

                        if (shouldEdit == true) {
                          // TODO: Implement edit functionality
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng đang được phát triển'),
                              ),
                            );
                          }
                        }
                      } else if (value == 'delete') {
                        final shouldDelete = await ConfirmationDialog.show(
                          context: context,
                          title: 'Xác nhận xóa',
                          message: 'Bạn có chắc chắn muốn xóa bài thi này?',
                          confirmText: 'Xóa',
                          isDestructive: true,
                        );

                        if (shouldDelete == true) {
                          try {
                            await _testService.deleteTest(test.id);
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
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageTransitions.slideTransition(const CreateTestScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
