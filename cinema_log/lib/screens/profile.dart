import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../models/app_user.dart';
import '../services/tracker_manager.dart';
import '../screens/movie_details_screen.dart';
import 'package:cinema_log/screens/search.dart';
import 'package:cinema_log/screens/custom_lists_screen.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/screens/stats_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  static late AppUser currentUser;
  static late TrackerManager trackerManager;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TrackerManager tracker = TrackerManager();
  int _selectedIndex = 3;

  // ADDED: load Firebase data
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ADDED
  Future<void> _loadData() async {
    await tracker.loadWatchHistory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final stats = tracker.calculateStatistics(
      filter: StatisticsFilterType.lifetime,
    );

    final history = tracker.getWatchHistory();

    int totalMoviesWatched = stats.totalMoviesWatched;
    int averageWatchedPerMonth = stats.averageWatchedPerMonth.round();
    String favoriteGenre = stats.mostViewedGenre;

    return Scaffold(
      backgroundColor: Colors.black,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 10),

            // Full Name
            Text(
              Profile.currentUser.fullName ?? "No Name",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
                  "Email: ${Profile.currentUser.email ?? 'Loading...'}",
                  style: const TextStyle(color: Colors.grey),
                ),

            const SizedBox(height: 30),
            // ===== SETTINGS UI =====
            Center(
              child: Container(
                width: 375,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101728),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector( 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StatsScreen()),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('View Your Statistics', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Update Password', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Update Email', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Color(0xFFFB2C36)),
                          SizedBox(width: 8),
                          Text('Sign Out', style: TextStyle(color: Color(0xFFFB2C36), fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever_rounded, color: Color(0xFFFB2C36)),
                          SizedBox(width: 8),
                          Text('Delete Account', style: TextStyle(color: Color(0xFFFB2C36), fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
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
            Profile.currentUser = WelcomeUser.currentUser;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border),label: 'Lists',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
