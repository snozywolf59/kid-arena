import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/class.dart';
import '../models/student.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy user ID hiện tại
  String? get currentUserId => _auth.currentUser?.uid;

  // Lấy danh sách lớp học do người dùng quản lý
  Stream<List<Class>> getClassesForTeacherUser() {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Class.fromFirestore(doc)).toList();
        });
  }

  // Lấy thông tin chi tiết của một lớp học
  Future<Class?> getClassById(String classId) async {
    DocumentSnapshot doc =
        await _firestore.collection('classes').doc(classId).get();

    if (doc.exists) {
      return Class.fromFirestore(doc);
    }
    return null;
  }

  // Thêm lớp học mới
  Future<String> addClass(String name, String description) async {
    try {
      DocumentReference docRef = await _firestore.collection('classes').add({
        'name': name,
        'description': description,
        'studentIds': [],
        'teacherId': currentUserId,
        'createdAt': Timestamp.now(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Không thể thêm lớp học: $e');
    }
  }

  /// Thêm học sinh vào lớp.
  /// Giáo viên nhập username học sinh. Tìm id doc học sinh trong firebase.
  Future<void> addStudentToClass(String classId, String studentUsername) async {
    try {
      Class? classData = await getClassById(classId);
      if (classData == null) {
        throw Exception('Không tìm thấy lớp học');
      }
      final QuerySnapshot studentDoc =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: studentUsername)
              .limit(1)
              .get();
      String studentId = studentDoc.docs.first.id;
      if (classData.students.contains(studentId)) {
        throw Exception('Học sinh đã có trong lớp');
      }

      // Thêm học sinh vào lớp
      await _firestore.collection('classes').doc(classId).update({
        'students': FieldValue.arrayUnion([studentId]),
      });
    } catch (e) {
      throw Exception('Không thể thêm học sinh vào lớp: $e');
    }
  }

  // Xóa học sinh khỏi lớp
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    try {
      await _firestore.collection('classes').doc(classId).update({
        'studentIds': FieldValue.arrayRemove([studentId]),
      });
    } catch (e) {
      throw Exception('Không thể xóa học sinh khỏi lớp: $e');
    }
  }

  // Xóa lớp học
  Future<void> deleteClass(String classId) async {
    try {
      await _firestore.collection('classes').doc(classId).delete();
    } catch (e) {
      throw Exception('Không thể xóa lớp học: $e');
    }
  }

  // Lấy danh sách học sinh trong lớp
  Future<List<Student>> getStudentsInClass(String classId) async {
    try {
      Class? classData = await getClassById(classId);
      if (classData == null) {
        throw Exception('Không tìm thấy lớp học');
      }

      List<Student> students = [];
      for (String studentId in classData.students) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(studentId).get();
        if (doc.exists) {
          students.add(Student.fromFirestore(doc));
        }
      }
      return students;
    } catch (e) {
      throw Exception('Không thể lấy danh sách học sinh: $e');
    }
  }

  Stream<List<Class>> getClassesForStudentUser() {
    return _firestore
        .collection('classes')
        .where('students', arrayContains: currentUserId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Class.fromFirestore(doc)).toList(),
        );
  }

  //get classes for a student
  Future<List<Class>> getClassesForStudent(String studentId) async {
    final snapshot = await _firestore.collection('classes').where('students', arrayContains: studentId).get();
    return snapshot.docs.map((doc) => Class.fromFirestore(doc)).toList();
  }

  //get classes for a teacher
}
