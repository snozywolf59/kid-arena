import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<Map<String, String>> getStudentNames(List<String> studentIds) async {
    try {
      final QuerySnapshot result =
          await _firestore
              .collection(_usersCollection)
              .where(FieldPath.documentId, whereIn: studentIds)
              .where('role', isEqualTo: 'student')
              .get();

      final Map<String, String> studentNames = {};
      for (var doc in result.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String fullName = data['fullName'] ?? '';
        studentNames[doc.id] =
            fullName.trim().isEmpty ? 'Unknown Student' : fullName;
      }

      return studentNames;
    } catch (e) {
      throw Exception('Failed to get student names: $e');
    }
  }
}
