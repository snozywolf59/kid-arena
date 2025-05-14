import 'package:flutter/material.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/student.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';
import 'package:kid_arena/widgets/common/custom_snackbar.dart';

class ManageStudentsScreen extends StatefulWidget {
  final Class classroom;

  const ManageStudentsScreen({super.key, required this.classroom});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final _studentUsernameQueryController = TextEditingController();
  final _addStudentController = TextEditingController();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _studentUsernameQueryController.dispose();
    _addStudentController.dispose();
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
        _filteredStudents = students;
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

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents =
          _students.where((student) {
            return student.fullName.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                student.username.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _showAddStudentDialog() async {
    _addStudentController.clear();
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm học sinh'),
            content: TextField(
              controller: _addStudentController,
              decoration: const InputDecoration(
                labelText: 'Username học sinh',
                hintText: 'Nhập username của học sinh',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  _addStudent();
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  Future<void> _addStudent() async {
    final studentId = _addStudentController.text.trim();
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
    CustomSnackBar.showSuccess(context, message);
  }

  void _showErrorMessage(String error) {
    CustomSnackBar.showError(context, error);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBarWidget(
        controller: _studentUsernameQueryController,
        hintText: 'Tìm kiếm học sinh...',
        onSearch: _filterStudents,
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentListItem(student);
      },
    );
  }

  Widget _buildStudentListItem(Student student) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onTertiary)],
      ),
      child: ListTile(
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

    return Scaffold(
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
          children: [_buildSearchBar(), Expanded(child: _buildStudentList())],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        label: const Text('Thêm học sinh'),
        icon: const Icon(Icons.add_box_rounded),
      ),
    );
  }
}
