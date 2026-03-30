import 'package:flutter/material.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/screens/login.dart';
import 'package:cinema_log/models/app_user.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_log/firebase_options.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:auto_route/auto_route.dart';
//import 'app_router.gr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Controller appController = Controller();
  await appController.getPopularMedia();
  await appController.getUpcomingMovies();
  AppUser currentUser = AppUser.anonymous();
  WelcomeUser.currentUser = currentUser;
  runApp(CinemaLog());
}

class CinemaLog extends StatelessWidget {
  const CinemaLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF615FFF),
          brightness: Brightness.dark,
        ),
      ),
      home: Welcome_new(),
    );
    //throw UnimplementedError();
  }
}
