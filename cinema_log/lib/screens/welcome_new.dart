import 'package:cinema_log/screens/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cinema_log/screens/sign_up.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/main.dart';
import 'package:cinema_log/models/app_user.dart';

class Welcome_new extends StatefulWidget{
  Welcome_new({super.key});
  
  late AppUser curentUser;
  static late List popMedia;
  static late List upcomingMovies;


  @override
  _WelcomeNewScreenState createState() => _WelcomeNewScreenState();
}

class _WelcomeNewScreenState extends State<Welcome_new>{
    
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      //header bar with logo
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
      body: Column( 
        children: <Widget>[
          //Welcome text
          Text(  
            'Welcome!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              height: 1.11,
              letterSpacing: -1.80,
            ),
          ),
          //Subtitle text
          SizedBox(
                width: 280,
                child: Text(
                  'Please sign in or create an account to start tracking what you watch',
                  style: TextStyle(
                    color: const Color(0xFF99A1AF),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                )
          ),
          //Buttons for signing up and glogging in
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: ElevatedButton(
              onPressed: () { //sends user to sign up screen after pressing 
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => Sign_Up()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF4F39F6)),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Sign up'),
              ),
          ),
          ElevatedButton(
              onPressed: () { //sends user to login screen after pressing
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => Login()),
                );
              }, 
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Color(0x874F39F6)),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
            child: const Text('Log in')),
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
                  return Container(
                    width: 160,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      image : DecorationImage(
                        image: NetworkImage(Controller.mainImgURL + Welcome_new.popMedia[index]['poster_path']) //image path
                      )
                    )
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
                  return Container(
                    width: 160,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      image : DecorationImage(
                        image: NetworkImage(Controller.mainImgURL + Welcome_new.upcomingMovies[index]['poster_path'])
                      )
                    )
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
            icon: Icon(Icons.bookmark_border),//List tab
            label: 'Lists'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),//Profile tab
            label: 'Profile'),
        ],
      ), //for navigation at bottom of screen
      );
    }
}



