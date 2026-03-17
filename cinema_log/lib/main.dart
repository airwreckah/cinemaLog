import 'package:flutter/material.dart';
import 'package:cinema_log/screens/welcome.dart';

void main(){
  runApp(CinemaLog());
} 

class CinemaLog extends StatelessWidget{
  const CinemaLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF615FFF),
          brightness: Brightness.dark
        ),
      ),
      home: const Welcome(),
    );
    //throw UnimplementedError();
  }
}