import 'package:cinema_log/screens/login.dart';
import 'package:cinema_log/screens/movie.dart';
import '../models/app_user.dart';
import '../services/tracker_manager.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/main.dart';

class WelcomeUser extends StatefulWidget{
  const WelcomeUser({super.key});
  static late AppUser currentUser;
  static late List popMedia;
  static late List upcomingMovies;


  @override
  _WelcomeUserScreenState createState() => _WelcomeUserScreenState();
}

class _WelcomeUserScreenState extends State<WelcomeUser>{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      //header bar with logo
      appBar: AppBar( 
        automaticallyImplyLeading: false,
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
      body: Column( 
        children: <Widget>[
          if(WelcomeUser.currentUser.watchHistoryNotEmpty())
            Container(
            height: 28.01,
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            child: Row(
              children: <Widget>[ Text( 'Your Recently Watched',   
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
              )
              )
              ]
            ),
          ),
          if(!WelcomeUser.currentUser.watchHistoryNotEmpty())
            Container(
            height: 28.01,
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            child: Row(
              children: <Widget>[ Text( 'Your Recently Watched',   
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                )
                ),
              ]
            ),
            ),
            Text('Please add movies to your watched list'),
          //header for popular section
          Container(
            height: 28.01,
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            child: Row(
              children: <Widget>[ Text( 'Popular',   
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
              )
              )
              ]
            ),
          ),
          
          //Shows the scrollable list of movies
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            height: 200,
            child: ScrollConfiguration(behavior: const MaterialScrollBehavior().copyWith(dragDevices: {...PointerDeviceKind.values}), 
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Welcome_new.popMedia.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image : DecorationImage(
                          image: NetworkImage(Controller.mainImgURL + WelcomeUser.popMedia[index]['poster_path'] + Controller.apiKey) //image path
                        )
                      )
                    ),
                    onTap:(){
                       Navigator.push(context, MaterialPageRoute<void>(builder: (context) => Movie()));
                    }
                  );
                },
              ),
            ),
          ),
          //Title for Upcoming list
          Container(
            height: 28.01,
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            child: Row(
              children: <Widget>[ Text( 'Upcoming',   
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                )
              )
              ]
            ),
          ),
          //Scrollable list
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            padding: const EdgeInsets.symmetric(horizontal: 23.99),
            height: 200,
            child: ScrollConfiguration(behavior: const MaterialScrollBehavior().copyWith(dragDevices: {...PointerDeviceKind.values}), 
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Welcome_new.popMedia.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image : DecorationImage(
                          image: NetworkImage(Controller.mainImgURL + Welcome_new.upcomingMovies[index]['poster_path'] + Controller.apiKey)
                        )
                      )
                    ),
                    onTap:(){
                       Navigator.push(context, MaterialPageRoute<void>(builder: (context) => Movie()));
                    }
                  );
                },
              )
            ),
          )
          ]
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
            label: 'Profile'),
        ],
      ), //for navigation at bottom of screen
      );
    }
}