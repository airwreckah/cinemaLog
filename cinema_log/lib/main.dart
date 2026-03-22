import 'package:flutter/material.dart';
import 'package:cinema_log/screens/welcome.dart';
import 'package:google_fonts/google_fonts.dart';

void main(){
  runApp(CinemaLog());
} 

class CinemaLog extends StatelessWidget{
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