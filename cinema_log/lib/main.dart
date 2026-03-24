import 'package:flutter/material.dart';
import 'package:cinema_log/screens/welcome.dart';
import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/screens/login.dart';
import 'package:cinema_log/screens/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_log/firebase_options.dart';
//import 'package:auto_route/auto_route.dart';
//import 'app_router.gr.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CinemaLog());
} 


class CinemaLog extends StatelessWidget{
  const CinemaLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF615FFF),
          brightness: Brightness.dark
        ),

      ),
      home:  Welcome(),
    );
    //throw UnimplementedError();
  }
}

