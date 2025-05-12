import 'package:get_it/get_it.dart';
import 'package:kid_arena/services/class_service.dart';
import 'package:kid_arena/services/auth_service.dart';
import 'package:kid_arena/services/test_service.dart';
import 'package:kid_arena/services/study_streak_service.dart';

final getIt = GetIt.instance;

Future<void> getItInit() async {
  getIt.registerSingleton<AuthService>(AuthServiceImpl());
  getIt.registerLazySingleton<ClassService>(() => ClassService());
  getIt.registerLazySingleton<TestService>(() => TestService());
  getIt.registerLazySingleton<StudyStreakService>(() => StudyStreakService());
}
