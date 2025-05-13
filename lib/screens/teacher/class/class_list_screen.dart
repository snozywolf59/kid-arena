// Dart packages
import 'dart:developer';

// Flutter packages
import 'package:flutter/material.dart';

// Pub packages

// Project packages
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/screens/teacher/class_details/add_class_screen.dart';
import 'package:kid_arena/screens/teacher/class_details/class_detail_screen.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:kid_arena/widgets/common/search_bar_widget.dart';
import 'package:kid_arena/widgets/confirmation_dialog.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: $error'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      PageTransitions.slideTransition(ClassDetailScreen(classroom: classroom)),
    );
  }

  void _navigateToAddClass() {
    Navigator.push(
      context,
      PageTransitions.slideTransition(const AddClassScreen()),
    );
  }

  List<Class> _filterClasses(List<Class> classes) {
    if (_searchQuery.isEmpty) return classes;
    return classes.where((classroom) {
      return classroom.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          classroom.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SearchBarWidget(
        controller: _searchController,
        hintText: 'Tìm kiếm lớp học...',
        onSearch: (value) {
          if (value != _searchQuery) {
            setState(() {
              _searchQuery = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildClassList(List<Class> classes) {
    final filteredClasses = _filterClasses(classes);

    if (filteredClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy lớp học nào',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredClasses.length,
      itemBuilder: (context, index) {
        final classroom = filteredClasses[index];
        return _buildClassCard(classroom);
      },
    );
  }

  Widget _buildClassCard(Class classroom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.slideTransition(
              ClassDetailScreen(classroom: classroom),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classroom.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildClassActions(classroom),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classroom.students.length} học sinh',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tạo ngày ${classroom.createdAt.day}/${classroom.createdAt.month}/${classroom.createdAt.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          tooltip: 'Quản lý lớp',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteConfirmationDialog(classroom),
          tooltip: 'Xóa lớp',
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lớp học nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm lớp học mới',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildClassList(classes)),
          ],
        );
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
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddClass,
        icon: const Icon(Icons.add),
        label: const Text('Thêm lớp'),
      ),
    );
  }
}
