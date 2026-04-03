import 'package:cinema_log/models/statistics.dart';
import 'package:cinema_log/services/tracker_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../screens/welcome_user.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/search.dart';
import 'package:cinema_log/main.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  static late AppUser currentUser;
  static late Statistics userStats;
  static late TrackerManager trackerManager;
  
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  int _selectedIndex = 3;
  TrackerManager tracker = Profile.trackerManager;
  StatisticsFilterType statFilter = StatisticsFilterType.lifetime;
  late Statistics stats = tracker.calculateStatistics(filter: statFilter);
  int get totalMoviesWatched => stats.totalMoviesWatched;
  late String totalMoviesStr = totalMoviesWatched.toString();
  int get averageWatchedPerMonth => stats.averageWatchedPerMonth.round();
  late String averageWatchedPerMonthStr = averageWatchedPerMonth.toString();
  String get favoriteGenre => stats.mostViewedGenre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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

            // Profile Icon
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: ShapeDecoration(
                color: const Color(0xFFEADDFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Icon(Icons.person, size: 100.0),
            ),

            // Full Name
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                Profile.currentUser.fullName ?? "No Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w900,
                  height: 1.33,
                  letterSpacing: -1.20,
                ),
              ),
            ),

            // ADDED: UID, EMAIL, AGE
            Column(
              children: [
                Text(
                  "UID: ${Profile.currentUser.uid ?? "Loading..."}",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Email: ${Profile.currentUser.email ?? "Loading..."}",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Age: ${Profile.currentUser.age ?? "Loading..."}",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "Watchlists: ${Profile.currentUser.mediaLists.length}",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            Row(
              spacing: 50,
              children: <Widget>[
                Container(
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
                        totalMoviesStr,
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
                        averageWatchedPerMonthStr,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 30,
                          fontWeight: FontWeight.w700)
                          ),
                        ),

                      SizedBox(height: 2),
                      Padding( 
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                        'Average Watched/Month',
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
              width: 375,
              height: 150,
              margin: EdgeInsets.only(top: 20),
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              decoration: BoxDecoration(color: const Color(0xFF101728)),
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
                        child: Text('Favorite Genre',
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
                  Padding( 
                    padding: EdgeInsets.only(left: 32, top: 10),
                    child: Text(favoriteGenre,
                    style: TextStyle(
                      color: const Color(0xFFBEDBFF),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                    ),
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
                color: const Color(0xFF101728),
                borderRadius: BorderRadius.circular(12),
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
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_rounded,
                        color: const Color(0xFFFB2C36),
                        ),
                        Text('Delete Account',
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomListsScreen()),
            );
          } else if (index == 3) {
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
