import 'package:get_it/get_it.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/services/test_service.dart';

final getIt = GetIt.instance;

Future<void> getItInit() async {
  getIt.registerSingleton<AuthService>(AuthServiceImpl());
  getIt.registerSingleton<ClassService>(ClassService());
  getIt.registerSingleton<TestService>(TestService());
}
