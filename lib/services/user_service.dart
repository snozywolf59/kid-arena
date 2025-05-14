import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kid_arena/models/user/index.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  void setCurrentUser(AppUser user) {
    _currentUser = user;
  }

  void clearCurrentUser() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromFirebase(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
