// Dart packages
import 'dart:developer';

// Flutter packages
import 'package:flutter/material.dart';

// Pub packages

// Project packages
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/teacher/add_class_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/manage_students_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/class_detail_screen.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  bool _isLoading = false;

  Future<void> _deleteClass(String classId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await getIt<ClassService>().deleteClass(classId);
      if (mounted) {
        _showSuccessMessage('Xóa lớp học thành công');
      }
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

  void _showDeleteConfirmationDialog(Class classroom) {
    ConfirmationDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa lớp ${classroom.name}?',
      confirmText: 'Xóa',
      isDestructive: true,
    ).then((shouldDelete) {
      if (shouldDelete == true) {
        _deleteClass(classroom.id);
      }
    });
  }

  void _navigateToManageStudents(Class classroom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageStudentsScreen(classroom: classroom),
      ),
    );
  }

  void _navigateToAddClass() {
    Navigator.push(
      context,
      PageTransitions.slideTransition(const AddClassScreen()),
    );
  }

  Widget _buildClassList(List<Class> classes) {
    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classroom = classes[index];
        return _buildClassCard(classroom);
      },
    );
  }

  Widget _buildClassCard(Class classroom) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(classroom.name),
        subtitle: Text(classroom.description),
        trailing: _buildClassActions(classroom),
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.slideTransition(
              ClassDetailScreen(classroom: classroom),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassActions(Class classroom) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: () => _navigateToManageStudents(classroom),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmationDialog(classroom),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text(
        'Đã xảy ra lỗi: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Chưa có lớp học nào'));
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    return StreamBuilder<List<Class>>(
      stream: getIt<ClassService>().getClassesForTeacherUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          log(snapshot.error.toString());
          return _buildErrorWidget(snapshot.error.toString());
        }

        final classes = snapshot.data ?? [];

        if (classes.isEmpty) {
          return _buildEmptyState();
        }

        return _buildClassList(classes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách lớp học'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddClass,
        child: const Icon(Icons.add),
      ),
    );
  }
}
