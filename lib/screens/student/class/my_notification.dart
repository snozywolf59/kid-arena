import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyNotification extends StatefulWidget {
  const MyNotification({super.key});

  @override
  State<MyNotification> createState() => _MyNotificationState();
}

class _MyNotificationState extends State<MyNotification> {
  final List<StudentNotification> _notifications = [
    StudentNotification(
      title: 'Bài tập mới: Toán',
      body: 'Bài tập chương 3 đã được đăng. Hạn nộp: 15/05/2024',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      type: NotificationType.assignment,
      subject: 'Toán',
    ),
    StudentNotification(
      title: 'Điểm kiểm tra Văn',
      body: 'Điểm bài kiểm tra giữa kỳ đã có. Bạn được 8.5 điểm',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      type: NotificationType.grade,
      subject: 'Ngữ Văn',
    ),
    StudentNotification(
      title: 'Lịch học thay đổi',
      body: 'Lịch học thứ 5 sẽ dời sang sáng thứ 7 tuần này',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      type: NotificationType.schedule,
    ),
    StudentNotification(
      title: 'Thông báo từ lớp trưởng',
      body: 'Nhớ mang đồng phục thể dục cho buổi học ngày mai',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.announcement,
      sender: 'Nguyễn Văn A',
    ),
    StudentNotification(
      title: 'Hoạt động ngoại khóa',
      body: 'Đăng ký tham gia câu lạc bộ Robotics trước 10/05',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      type: NotificationType.event,
    ),
  ];

  bool _showUnreadOnly = false;
  NotificationType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredNotifications =
        _notifications.where((notification) {
          if (_showUnreadOnly && notification.isRead) return false;
          if (_selectedFilter != null && notification.type != _selectedFilter) {
            return false;
          }
          return true;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo của bạn'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterOptions,
            tooltip: 'Lọc thông báo',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedFilter != null || _showUnreadOnly)
            _buildActiveFiltersChip(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  filteredNotifications.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Không có thông báo nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: () async {
                          // Simulate refresh
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() {});
                        },
                        child: ListView.separated(
                          itemCount: filteredNotifications.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_showUnreadOnly)
            InputChip(
              label: const Text('Chưa đọc'),
              onDeleted: () {
                setState(() {
                  _showUnreadOnly = false;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          if (_selectedFilter != null)
            InputChip(
              label: Text(_getNotificationTypeLabel(_selectedFilter!)),
              onDeleted: () {
                setState(() {
                  _selectedFilter = null;
                });
              },
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(StudentNotification notification) {
    final timeAgo = _formatTimeAgo(notification.createdAt);
    final icon = _getNotificationIcon(notification.type);
    final color = _getNotificationColor(notification.type);

    return InkWell(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        _showNotificationDetails(notification);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:
              notification.isRead
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                notification.isRead
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (notification.subject != null ||
                      notification.sender != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notification.subject ?? 'Từ: ${notification.sender!}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(StudentNotification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      size: 20,
                      color: _getNotificationColor(notification.type),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notification.subject != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.subject, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        notification.subject!,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              if (notification.sender != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Từ: ${notification.sender!}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(
                        'HH:mm dd/MM/yyyy',
                      ).format(notification.createdAt),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(notification.body, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        );
      },
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

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  SwitchListTile(
                    title: const Text('Chỉ hiển thị chưa đọc'),
                    value: _showUnreadOnly,
                    onChanged: (value) {
                      setModalState(() {
                        _showUnreadOnly = value;
                      });
                    },
                  ),
                  const Divider(),
                  const Text(
                    'Loại thông báo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...NotificationType.values.map((type) {
                    return RadioListTile<NotificationType>(
                      title: Text(_getNotificationTypeLabel(type)),
                      value: type,
                      groupValue: _selectedFilter,
                      onChanged: (value) {
                        setModalState(() {
                          _selectedFilter = value;
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _showUnreadOnly = false;
                              _selectedFilter = null;
                            });
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return Icons.assignment;
      case NotificationType.grade:
        return Icons.grade;
      case NotificationType.schedule:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.announcement;
      case NotificationType.event:
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return Colors.blue;
      case NotificationType.grade:
        return Colors.green;
      case NotificationType.schedule:
        return Colors.orange;
      case NotificationType.announcement:
        return Colors.purple;
      case NotificationType.event:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.assignment:
        return 'Bài tập';
      case NotificationType.grade:
        return 'Điểm số';
      case NotificationType.schedule:
        return 'Lịch học';
      case NotificationType.announcement:
        return 'Thông báo';
      case NotificationType.event:
        return 'Sự kiện';
      default:
        return 'Khác';
    }
  }
}

class StudentNotification {
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
  final NotificationType type;
  final String? subject;
  final String? sender;

  StudentNotification({
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.subject,
    this.sender,
  });
}

enum NotificationType { assignment, grade, schedule, announcement, event }
