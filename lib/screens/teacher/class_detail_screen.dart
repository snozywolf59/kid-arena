import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/student.dart';
import 'package:kid_arena/models/test.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/get_it.dart';
import 'package:kid_arena/screens/teacher/manage_students_screen.dart';
import 'package:kid_arena/screens/teacher/create_test_screen.dart';
import 'package:kid_arena/utils/page_transitions.dart';

class ClassDetailScreen extends StatefulWidget {
  final Class classroom;

  const ClassDetailScreen({super.key, required this.classroom});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Student> _students = [];
  List<Test> _tests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load students
      final students = await getIt<ClassService>().getStudentsInClass(
        widget.classroom.id,
      );
      setState(() {
        _students = students;
      });

      // Load tests
      final tests =
          await getIt<TestService>()
              .getTestsForClass(widget.classroom.id)
              .first;
      setState(() {
        _tests = tests;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStudentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_students.isEmpty) {
      return const Center(child: Text('Chưa có học sinh nào trong lớp'));
    }

    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(student.fullName),
          subtitle: Text('Username: ${student.username}'),
        );
      },
    );
  }

  Widget _buildTestList() {
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
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: Text(
                          'Bạn có chắc chắn muốn xóa bài thi ${test.title}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Học sinh'), Tab(text: 'Bài thi')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStudentList(), _buildTestList()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_tabController.index == 0) {
            // Navigate to manage students screen
            await Navigator.push(
              context,
              PageTransitions.slideTransition(
                ManageStudentsScreen(classroom: widget.classroom),
              ),
            );
            await _loadData();
          } else {
            // Navigate to create test screen
            await Navigator.push(
              context,
              PageTransitions.slideTransition(
                CreateTestScreen(classId: widget.classroom.id),
              ),
            );
            await _loadData();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
