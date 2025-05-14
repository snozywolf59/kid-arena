import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String activityType;
  final String title;
  final String description;
  final DateTime timestamp;

    Activity({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    required this.timestamp,
  });


  //from firestore
  factory Activity.fromFirestore(DocumentSnapshot doc) {
    return Activity(
      id: doc.id,
      activityType: doc['activityType'],
      title: doc['title'],
      description: doc['description'],
      timestamp: doc['timestamp'].toDate(),
    );
  }

  //to map
  Map<String, dynamic> toMap() {  
    return {
      'activityType': activityType,
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }
}