import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kid_arena/get_it.dart';
import 'package:kid_arena/models/notification.dart';
import 'package:kid_arena/services/class_service.dart';

class NotificationService {
  final _collection = 'notifications';
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> sendNotification(ClassNotification notification) async {
    await _firestore.collection(_collection).add(notification.toMap());
  }

  //get notifications for a class
  Future<List<ClassNotification>> getNotificationsForClass(
    String classId
  ) async {
    log('Lấy noti từ lớp ${classId}');
    final snapshot =
        await _firestore
            .collection(_collection)
            .where('classId', isEqualTo: classId)
            .get();
    return snapshot.docs
        .map((doc) => ClassNotification.fromFirestore(doc))
        .toList();
  }

  //get notifications for a student
  Future<List<ClassNotification>> getNotificationsForStudent(
    String studentId,
  ) async {
    final classes = await getIt<ClassService>().getClassesForStudent(studentId);
    final notifications = <ClassNotification>[];
    for (final classData in classes) {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('classId', isEqualTo: classData.id)
              .get();
      notifications.addAll(
        snapshot.docs.map((doc) => ClassNotification.fromFirestore(doc)),
      );
    }
    return notifications;
  }
}
