import 'package:get_it/get_it.dart';
import 'package:kid_arena/service/firebase_service.dart';

final getIt = GetIt.instance;

Future<void> getItInit() async {
  getIt.registerSingleton<AuthService>(AuthServiceImpl());
}
