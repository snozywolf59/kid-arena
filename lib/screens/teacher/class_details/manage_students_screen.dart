import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/student.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

class ManageStudentsScreen extends StatefulWidget {
  final Class classroom;

  const ManageStudentsScreen({super.key, required this.classroom});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _studentUsernameQueryController = TextEditingController();
  List<Student> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _studentUsernameQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final students = await getIt<ClassService>().getStudentsInClass(
        widget.classroom.id,
      );
      setState(() {
        _students = students;
      });
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addStudent() async {
    final studentId = _studentUsernameQueryController.text.trim();
    if (studentId.isEmpty) {
      _showErrorMessage('Vui lòng nhập ID học sinh');
      return;
    }

    final shouldAdd = await ConfirmationDialog.show(
      context: context,
      title: 'Xác nhận thêm học sinh',
      message:
          'Bạn có chắc chắn muốn thêm học sinh có username $studentId vào lớp?',
      confirmText: 'Thêm',
      isDestructive: false,
    );

    if (shouldAdd != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await getIt<ClassService>().addStudentToClass(
        widget.classroom.id,
        studentId,
      );
      _studentUsernameQueryController.clear();
      await _loadStudents();
      if (mounted) {
        _showSuccessMessage('Thêm học sinh thành công');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi khi thêm học sinh: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeStudent(String studentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await getIt<ClassService>().removeStudentFromClass(
        widget.classroom.id,
        studentId,
      );
      await _loadStudents();
      if (mounted) {
        _showSuccessMessage('Xóa học sinh thành công');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Lỗi khi xóa học sinh: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lỗi: $error')));
  }

  Widget _buildAddStudentForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(
              controller: _studentUsernameQueryController,
              hintText: 'Tìm kiếm học sinh...',
              onSearch: (value) {
                _studentUsernameQueryController.text = value;
              },
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add_box_rounded),
            label: const Text('Thêm học sinh'),
            onPressed: _addStudent,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentListItem(student);
      },
    );
  }

  Widget _buildStudentListItem(Student student) {
    return ListTile(
      leading: CircleAvatar(child: Text(student.fullName[0])),
      title: Text(student.fullName),
      subtitle: Text(student.username),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () async {
          final shouldRemove = await ConfirmationDialog.show(
            context: context,
            title: 'Xác nhận xóa',
            message:
                'Bạn có chắc chắn muốn xóa học sinh ${student.fullName} khỏi lớp?',
            confirmText: 'Xóa',
            isDestructive: true,
          );

          if (shouldRemove == true) {
            _removeStudent(student.id);
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    return Column(
      children: [_buildAddStudentForm(), Expanded(child: _buildStudentList())],
    );
  }
}
