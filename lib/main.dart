import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kid_arena/firebase_options.dart';
import 'package:kid_arena/screens/splash_screen.dart';
import 'package:kid_arena/services/getIt.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await getItInit();
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kid Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
