import 'package:cloud_firestore/cloud_firestore.dart';

class ClassNotification {
  final String id;
  final String title;
  final String body;
  final String classId;
  final DateTime createdAt;

  ClassNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.classId,
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
      createdAt: data['createdAt'].toDate(),
    );
  }

  //to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'classId': classId,
      'createdAt': createdAt,
    };
  }
}
