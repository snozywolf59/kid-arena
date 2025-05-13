import 'package:get_it/get_it.dart';
import 'package:kid_arena/services/index.dart';

final getIt = GetIt.instance;

Future<void> getItInit() async {
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<AuthService>(AuthServiceImpl());

  getIt.registerLazySingleton<ClassService>(() => ClassService());
  getIt.registerLazySingleton<TestService>(() => TestService());
  getIt.registerLazySingleton<StudyStreakService>(() => StudyStreakService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
}
