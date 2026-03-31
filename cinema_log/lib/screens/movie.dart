import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/main.dart';

class Movie extends StatefulWidget{
  final int mediaId;
  final String mediaTitle;
  final String mediaDesc;
  final String mediaPoster;
  
  Movie({super.key, 
    required this.mediaId, 
    required this.mediaTitle,
    required this.mediaDesc,
    required this.mediaPoster
    });
  

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<Movie>{
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