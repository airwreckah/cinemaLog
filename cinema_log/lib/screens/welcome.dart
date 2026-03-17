import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget{
  const Welcome({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<Welcome>{
  //controller for text
  final TextEditingController _controller = TextEditingController();
    
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('CinemaLog'), //header title
      ),
        body: Column( 
          children: <Widget>[
            Text('Welcome!\nPlease sign up or login to start tracking what you watch'),
            ElevatedButton(
              onPressed: null,
              child: const Text('Sign up'),
              ),
            ElevatedButton(onPressed: null, child: const Text('Log in')),
            SizedBox(
              height: 25,
             // color: Color(0xFF030712),
              child: const Center(child: Text( 'Popular', textAlign: TextAlign.justify)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              height: 200,
              child: ScrollConfiguration(behavior: const MaterialScrollBehavior().copyWith(dragDevices: {...PointerDeviceKind.values}), 
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:[
                  for(final color in Colors.primaries)
                    Container(width: 160, color:color),
                        ],
                      )
                    ),
                  ),
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
              label: 'Profile',
              ),
          ],
        ), //for navigation at bottom of screen
      );
    }
}



