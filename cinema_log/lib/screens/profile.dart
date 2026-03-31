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
      body: Column(children: <Widget>[
          Padding(padding: const EdgeInsetsGeometry.all(25),),
          Container( //person icon image
            padding: const EdgeInsets.all(20.0),
            decoration: ShapeDecoration(
            color: const Color(0xFFEADDFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
            child: Icon(
              Icons.person,
              size: 100.0)
          ),
          Container( //user's name
            padding: const EdgeInsets.all(20.0),
            child: Text("[User's Full Name]",
            style: TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
            ),),
          ),
          Row(
            spacing: 60.0,
            children: <Widget>[
              Container( //# movies watched
                margin: EdgeInsets.only(left: 20),
                width: 155.50,
                height: 126,
                decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.00),
                  end: Alignment(1.00, 1.00),
                  colors: [const Color(0xFF4F39F6), const Color(0xFF9810FA)],
                ),
                ),
              ),
              Container( //total watch time
                padding: EdgeInsets.only(right: 20),
                width: 155.50,
                height: 126,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, 0.00),
                    end: Alignment(1.00, 1.00),
                    colors: [const Color(0xFF155DFC), const Color(0xFF0092B8)],
                  ),
                ),
              )
            ],
          ),
          Container( //Most viewed genre
            width: 327,
            height: 118,
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            decoration: BoxDecoration(color: const Color(0xFF101828)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children:<Widget>[
                Icon(Icons.local_movies_outlined),
              ]
               
            ),
          ),
          Container( //settings text

          ),
          Container( //update password

          ),
          Container( //update email

          ),
          Container( //sign out button

          ),
        ],
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