import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../screens/welcome_user.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/search.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  static late AppUser currentUser;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile>{
  int _selectedIndex = 0;
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
          colors : [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            // Home tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeUser())
              );
          } else if (index == 1) {
            // Search tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search())
              );
          } else if (index == 2) {
            // Lists tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomListsScreen()),
            );
          } else if (index == 3) {
            // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile())
              );
          }
          setState(() {
            _selectedIndex = index;
          });
        },
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
            label: 'Profile'),
        ],
      ), //for navigat
    );
  }
}