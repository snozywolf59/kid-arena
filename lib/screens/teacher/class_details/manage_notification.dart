import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/notification.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/page_transitions.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/class.dart';
import 'package:kid_arena/models/notification.dart';
import 'package:kid_arena/services/index.dart';
import 'package:kid_arena/utils/page_transitions.dart';
import 'package:collection/collection.dart';

class NotificationManage extends StatefulWidget {
  final Class classroom;
  const NotificationManage({super.key, required this.classroom});

  @override
  State<NotificationManage> createState() => _NotificationManageState();
}

class _NotificationManageState extends State<NotificationManage> {
  List<ClassNotification> _notifications = [];
  final NotificationService _notificationService = getIt<NotificationService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  Future<void> _getNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notifications = await _notificationService.getNotificationsForClass(
        widget.classroom.id,
      );
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi lấy thông báo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<ClassNotification>> _groupNotificationsByDate() {
    return groupBy(_notifications, (notification) {
      final now = DateTime.now();
      final notificationDate = notification.createdAt;

      if (now.year == notificationDate.year &&
          now.month == notificationDate.month &&
          now.day == notificationDate.day) {
        return 'Hôm nay';
      } else if (now.year == notificationDate.year &&
          now.month == notificationDate.month &&
          now.day - notificationDate.day == 1) {
        return 'Hôm qua';
      } else {
        return DateFormat('dd/MM/yyyy').format(notificationDate);
      }
    });
  }

  void _navigateToCreateNotification() {
    Navigator.push(
      context,
      PageTransitions.slideTransition(
        CreateNotificationScreen(
          classroom: widget.classroom,
          onNotificationCreated: (notification) {
            _notificationService.sendNotification(notification);
            _getNotifications(); // Refresh list after creation
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateNotification,
        icon: const Icon(Icons.add),
        label: const Text('Tạo thông báo'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Chưa có thông báo nào',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để tạo thông báo mới',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _getNotifications,
      child: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    final groupedNotifications = _groupNotificationsByDate();
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final entry in groupedNotifications.entries)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
                child: Text(
                  entry.key,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entry.value
                  .map((notification) => _buildNotificationCard(notification))
                  .toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildNotificationCard(ClassNotification notification) {
    final theme = Theme.of(context);
    final isNew =
        DateTime.now().difference(notification.createdAt) <
        const Duration(days: 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle notification tap
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isNew)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(notification.body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '';
    }
  }
}

class CreateNotificationScreen extends StatefulWidget {
  final Class classroom;
  final Function(ClassNotification) onNotificationCreated;

  const CreateNotificationScreen({
    super.key,
    required this.classroom,
    required this.onNotificationCreated,
  });

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _createNotification() async {
    try {
      setState(() => _isLoading = true);
      if (!_formKey.currentState!.validate()) return;
      final notification = ClassNotification(
        id: '',
        classId: widget.classroom.id,
        className: widget.classroom.name,
        title: _titleController.text,
        body: _bodyController.text,
        createdAt: DateTime.now(),
      );

      widget.onNotificationCreated(notification);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi tạo thông báo ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        iconAlignment: IconAlignment.end,
        onPressed: _isLoading ? null : _createNotification,
        icon:
            _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.send, size: 24),
        label: const Text('Gửi', style: TextStyle(fontSize: 16)),
      ),
      appBar: AppBar(title: const Text('Tạo thông báo mới')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tên lớp: ${widget.classroom.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề thông báo',
                    hintText: 'Nhập tiêu đề thông báo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: 'Nội dung thông báo',
                    hintText: 'Nhập nội dung thông báo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNotificationCard(
  BuildContext context,
  ClassNotification notification,
) {
  final timeAgo = _formatTimeAgo(notification.createdAt);
  final isNew =
      DateTime.now().difference(notification.createdAt) <
      const Duration(days: 1);

  return InkWell(
    onTap: () {
      // Handle notification tap
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isNew)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.body,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Vừa xong';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} phút trước';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} ngày trước';
  } else {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

void _showFilterOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lọc thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFilterOption(context, 'Tất cả thông báo', true),
            _buildFilterOption(context, 'Chưa đọc', false),
            _buildFilterOption(context, 'Trong tuần', false),
            _buildFilterOption(context, 'Trong tháng', false),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildFilterOption(BuildContext context, String text, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          ),
        ),
      ],
    ),
  );
}
