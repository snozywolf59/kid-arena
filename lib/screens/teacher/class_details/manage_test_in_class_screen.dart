import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/test/index.dart';
import 'package:kid_arena/services/get_it.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
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

    if (_tests.isEmpty) {
      return const Center(child: Text('Chưa có bài thi nào'));
    }

    return ListView.builder(
      itemCount: _tests.length,
      itemBuilder: (context, index) {
        final test = _tests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(test.title),
            subtitle: Text(test.description),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final shouldDelete = await ConfirmationDialog.show(
                  context: context,
                  title: 'Xác nhận xóa',
                  message: 'Bạn có chắc chắn muốn xóa bài thi ${test.title}?',
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
                        SnackBar(content: Text('Lỗi khi xóa bài thi: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
