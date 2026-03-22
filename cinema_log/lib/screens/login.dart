import 'package:cinema_log/screens/sign_up.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login>{
  final TextEditingController _controller = TextEditingController();

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:  GradientText(
          'Cinema Log',
          style: TextStyle(
          fontSize: 30,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
          height: 1.33,
          letterSpacing: -1.20,
          ), 
          colors : [Color(0xFF615FFF), Color(0xFFAD46FF)],//header title
        ),
      ),
       bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),//Home tab
              label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),//Searflch tab
              label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),//List tab
              label: 'Lists'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),//Profile tab
              label: 'Profile',
              ),
          ],
        ), 
    );
  }
}