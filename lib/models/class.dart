import 'package:cloud_firestore/cloud_firestore.dart';

class Class {
  final String id;
  final String name;
  final String description;
  final List<dynamic> studentIds;
  final String teacherId;
  final DateTime createdAt;

  Class({
    required this.id,
    required this.name,
    required this.description,
    required this.studentIds,
    required this.teacherId,
    required this.createdAt,
  });

  factory Class.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Class(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      studentIds: data['studentIds'] ?? [],
      teacherId: data['teacherId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'studentIds': studentIds,
      'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
