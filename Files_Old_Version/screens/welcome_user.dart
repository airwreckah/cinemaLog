import 'package:cinema_log/screens/movie.dart';
import 'package:cinema_log/screens/profile.dart';
import 'package:cinema_log/screens/search.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import '../models/app_user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cinema_log/services/controller.dart';
import 'custom_lists_screen.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeUser extends StatefulWidget {
  const WelcomeUser({super.key});

  static late AppUser currentUser;
  static late List popMedia;
  static late List upcomingMovies;

  @override
  _WelcomeUserScreenState createState() => _WelcomeUserScreenState();
}

class _WelcomeUserScreenState extends State<WelcomeUser> {
  int _selectedIndex = 0;
  bool isLoading = true;

  // ✅ Load user data BEFORE UI renders
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      WelcomeUser.currentUser = AppUser.creation(
        user.uid,
        user.email,
        data?['fullName'] ?? '',
        data?['age']?.toString() ?? '',
      );

      // Sync profile screen
      Profile.currentUser = WelcomeUser.currentUser;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Prevent UI from rendering before data loads
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GradientText(
          'Cinema Log',
          style: const TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
          colors: const [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),

      // ✅ FIXED SCROLLING (vertical + horizontal)
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔹 Recently Watched
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Your Recently Watched',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            if (!WelcomeUser.currentUser.watchHistoryNotEmpty())
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Please add movies to your watched list',
                  style: TextStyle(color: Colors.white70),
                ),
              ),

            // 🔹 Popular Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(
              height: 200,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: WelcomeUser.popMedia.length,
                  itemBuilder: (context, index) {
                    final selectedMovie = WelcomeUser.popMedia[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Movie(movie: selectedMovie),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              Controller.mainImgURL +
                                  selectedMovie['poster_path'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 🔹 Upcoming Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Upcoming',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(
              height: 200,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: WelcomeUser.upcomingMovies.length,
                  itemBuilder: (context, index) {
                    final selectedMovie =
                        WelcomeUser.upcomingMovies[index]; // ✅ FIXED

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Movie(movie: selectedMovie),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              Controller.mainImgURL +
                                  selectedMovie['poster_path'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ FIXED NAVIGATION (no pushReplacement)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Search()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomListsScreen()),
            );
          } else if (index == 3) {
            Profile.currentUser = WelcomeUser.currentUser;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Profile()),
            );
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}