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

class _ProfileScreenState extends State<Profile> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GradientText(
          'Cinema Log',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Padding(padding: const EdgeInsetsGeometry.all(25)),
            Container(
              //person icon image
              padding: const EdgeInsets.all(20.0),
              decoration: ShapeDecoration(
                color: const Color(0xFFEADDFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Icon(Icons.person, size: 100.0),
            ),
            Container(
              //user's name
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "[User's Full Name]",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  height: 1.33,
                  letterSpacing: -1.20,
                ),
              ),
            ),
            Row(
              spacing: 50,
              children: <Widget>[
                Container(
                  //# movies watched
                  margin: EdgeInsets.only(left: 20),
                  width: 160,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, 0.00),
                      end: Alignment(1.00, 1.00),
                      colors: [
                        const Color(0xFF4F39F6),
                        const Color(0xFF9810FA),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      Padding( 
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Icon(Icons.local_movies_rounded,
                        color: Colors.white, size: 32),
                      ),
                      SizedBox(height: 10),
                      Padding( 
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 30,
                          fontWeight: FontWeight.w700)
                          ),
                        ),

                      SizedBox(height: 10),
                      Padding( 
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                        'Movies Watched',
                        style: TextStyle(color: const Color(0xFFBEDBFF), 
                        fontSize: 12, 
                        fontWeight: FontWeight.w400,
                        height: 1.33),
                      ),
                      ),
                    ],
                  ),
                ),
                Container(
                  //total watch time
                  padding: EdgeInsets.only(right: 20),
                  width: 160,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.00, 0.00),
                      end: Alignment(1.00, 1.00),
                      colors: [
                        const Color(0xFF155DFC),
                        const Color(0xFF0092B8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      Padding( 
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Icon(Icons.access_time,
                        color: Colors.white, size: 32),
                      ),
                      SizedBox(height: 10),
                      Padding( 
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                        '#Hrs',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 30,
                          fontWeight: FontWeight.w700)
                          ),
                        ),

                      SizedBox(height: 10),
                      Padding( 
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                        '#m Total Time',
                        style: TextStyle(color: const Color(0xFFBEDBFF), 
                        fontSize: 12, 
                        fontWeight: FontWeight.w400,
                        height: 1.33),
                      ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              //Most viewed genre
              width: 375,
              height: 150,
              margin: EdgeInsets.only(top: 20),
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              decoration: BoxDecoration(color: const Color(0xFF1E2939)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.movie_rounded,
                      color: const Color(0xFF615FFF),
                      ),
                      Padding( 
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Favorite Genres',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.56,
                        ),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: 324,
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  color: const Color(0xFF6A7282),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.43,
                  letterSpacing: 0.70,
                ),
              ),
            ),
            Container(
              width: 375,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2939),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Update Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                      letterSpacing: 0.70,
                    ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Update Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                      letterSpacing: 0.70,
                    ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.logout,
                        color: const Color(0xFFFB2C36),
                        ),
                        Text('Sign Out',
                        style: TextStyle(
                          color: const Color(0xFFFB2C36),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                          letterSpacing: 0.70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              MaterialPageRoute(builder: (context) => WelcomeUser()),
            );
          } else if (index == 1) {
            // Search tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search()),
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
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), //Home tab
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), //Searflch tab
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), //List tab
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), //Profile tab
            label: 'Profile',
          ),
        ],
      ), //for navigat
    );
  }
}
