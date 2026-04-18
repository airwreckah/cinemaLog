import 'package:cinema_log/services/tracker_manager.dart';
import 'package:flutter/material.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/models/app_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cinema_log/firebase_options.dart';
import 'package:cinema_log/services/controller.dart';
import 'screens/auth_wrapper.dart';
import 'screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Controller appController = Controller();
  await appController.init();
  await appController.getPopularMedia();
  await appController.getUpcomingMovies();

  AppUser currentUser = AppUser.anonymous();
  TrackerManager trackerManager = TrackerManager();

  Profile.trackerManager = trackerManager;
  WelcomeUser.currentUser = currentUser;

  runApp(const CinemaLog());
}

class CinemaLog extends StatelessWidget {
  const CinemaLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000814),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF000814),
          selectedItemColor: Color(0xFF615FFF),
          unselectedItemColor: Colors.white54,
        ),
      ),
      home: const AuthWrapper(),
    );
  } //throw UnimplementedError();
}