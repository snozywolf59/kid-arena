import 'package:kid_arena/models/user/index.dart';

class UserService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  void setCurrentUser(AppUser user) {
    _currentUser = user;
  }

  void clearCurrentUser() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}
