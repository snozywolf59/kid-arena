import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/notification.dart';
import 'package:kid_arena/services/index.dart';
import 'package:collection/collection.dart'; // Thêm thư viện này

class MyNotification extends StatefulWidget {
  final Future<List<ClassNotification>> notificationFuture;
  final bool showAppbar;

  const MyNotification({
    super.key,
    required this.notificationFuture,
    this.showAppbar = true,
  });

  @override
  State<MyNotification> createState() => _MyNotificationState();
}

class _MyNotificationState extends State<MyNotification> {
  List<ClassNotification> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final notifications = await widget.notificationFuture;
      setState(() {
        this.notifications = notifications;
      });
    } catch (e) {
      errorMessage = 'Error loading notifications: ${e.toString()}';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm nhóm thông báo theo ngày
  Map<String, List<ClassNotification>> _groupNotificationsByDate() {
    return groupBy(notifications, (notification) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar:
          widget.showAppbar
              ? AppBar(
                title: Text(
                  'Thông báo lớp học',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.primary,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _fetchNotifications,
                  ),
                ],
              )
              : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'Không có thông báo nào',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final groupedNotifications = _groupNotificationsByDate();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerLowest,
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: theme.colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final entry in groupedNotifications.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      entry.key,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (notification) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNotificationCard(notification),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(ClassNotification notification) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getClassColor(notification.classId),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notification.className,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('HH:mm').format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

  Color _getClassColor(String classId) {
    final theme = Theme.of(context);
    return theme.colorScheme.primary;
  }
}
