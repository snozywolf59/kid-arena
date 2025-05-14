import 'package:get_it/get_it.dart';
import 'package:kid_arena/services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> getItInit() async {
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<AuthService>(AuthServiceImpl());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<ClassService>(() => ClassService());
  getIt.registerLazySingleton<TestService>(() => TestService());
  getIt.registerLazySingleton<StudyStreakService>(() => StudyStreakService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<RankingService>(() => RankingService());
  getIt.registerLazySingleton<AchievementService>(() => AchievementService());
  getIt.registerLazySingleton<StudentService>(() => StudentService());
}
