import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kid_arena/firebase_options.dart';

class ClassNotification {
  final String id;
  final String title;
  final String body;
  final String classId;
  final String className;
  final DateTime createdAt;

  ClassNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.classId,
    required this.className,
    required this.createdAt,
  });

  //from firestore
  factory ClassNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassNotification(
      id: doc.id,
      title: data['title'],
      body: data['body'],
      classId: data['classId'],
      className: data['className'] ?? 'TẤT CẢ',
      createdAt: data['createdAt'].toDate(),
    );
  }

  //to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'classId': classId,
      'className': className,
      'createdAt': createdAt,
    };
  }
}

void main() async {
  final List<ClassNotification> notifications = [
    ClassNotification(
      id: 'notif_0',
      title: 'Nhắc nhở nộp bài tập',
      body: 'Vui lòng nộp bài tập về Widget trước 23:59 hôm nay.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 5, 9, 15),
    ),
    ClassNotification(
      id: 'notif_1',
      title: 'Buổi học hôm nay bị hoãn',
      body:
          'Lớp học lúc 19:00 hôm nay (06/05) sẽ được dời sang ngày mai cùng giờ.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 6, 12, 30),
    ),
    ClassNotification(
      id: 'notif_2',
      title: 'Tài liệu học tập mới',
      body:
          'Giáo trình về State Management đã được cập nhật trong Google Drive.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 7, 14, 45),
    ),
    ClassNotification(
      id: 'notif_3',
      title: 'Lịch kiểm tra giữa khóa',
      body:
          'Kiểm tra giữa khóa sẽ diễn ra vào ngày 10/05. Chuẩn bị ôn tập nhé!',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 7, 18, 00),
    ),
    ClassNotification(
      id: 'notif_4',
      title: 'Thông báo điểm danh',
      body: 'Vui lòng điểm danh trước 19:10 để được tính chuyên cần.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 8, 19, 00),
    ),
    ClassNotification(
      id: 'notif_5',
      title: 'Gợi ý học thêm',
      body:
          'Tham khảo video về Flutter Layout trên YouTube để nâng cao kỹ năng.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 9, 10, 00),
    ),
    ClassNotification(
      id: 'notif_6',
      title: 'Bài giảng bị lỗi âm thanh',
      body: 'Video buổi học ngày 08/05 sẽ được re-upload do lỗi kỹ thuật.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 10, 11, 20),
    ),
    ClassNotification(
      id: 'notif_7',
      title: 'Bài kiểm tra mẫu',
      body: 'Một bài kiểm tra mẫu đã được chia sẻ để các bạn luyện tập.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 11, 15, 45),
    ),
    ClassNotification(
      id: 'notif_8',
      title: 'Giải đáp thắc mắc trực tuyến',
      body: 'Sẽ có buổi Q&A trực tuyến lúc 20:00 tối nay qua Zoom.',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 13, 20, 00),
    ),
    ClassNotification(
      id: 'notif_9',
      title: 'Tổng kết tuần',
      body:
          'Tuần này chúng ta đã hoàn thành các chủ đề cơ bản về Flutter. Cố gắng duy trì nhé!',
      classId: 'uIusigTpD7drr2QnYpvd',
      className: 'Lớp 2B',
      createdAt: DateTime(2025, 5, 14, 16, 30),
    ),
  ];

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  for (final notification in notifications) {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification.toMap());
  }
}
