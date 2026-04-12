import 'package:cinema_log/screens/profile.dart';
import 'package:cinema_log/screens/search.dart';
import '../models/app_user.dart';
import '../services/tracker_manager.dart';
import 'package:cinema_log/screens/welcome_new.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cinema_log/services/controller.dart';
import 'custom_lists_screen.dart';
import 'movie_details_screen.dart';

// ADDED
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeUser extends StatefulWidget {
  const WelcomeUser({super.key});
  static late AppUser currentUser;
  static late List popMedia;
  static late List upcomingMovies;
  
  @override
  WelcomeUserScreenState createState() => WelcomeUserScreenState();
}

class WelcomeUserScreenState extends State<WelcomeUser> {
  int _selectedIndex = 0;
  final TrackerManager tracker = TrackerManager();

  List history = [];

  // ADDED FUNCTION
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      Profile.currentUser = AppUser.creation(
        user.uid,
        user.email,
        data?['fullName'] ?? '',
        data?['age']?.toString() ?? '',
      );
    }
  }

  // Load BOTH user + history properly
  Future<void> _loadAllData() async {
    await loadUserData();
    await tracker.loadWatchHistory();

    setState(() {
      history = tracker.getWatchHistory();
    });
  }

  // ADDED INITSTATE
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //header bar with logo
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
          children: <Widget>[
            if (!WelcomeUser.currentUser.watchHistoryNotEmpty())
              Container(
                height: 28.01,
                padding: const EdgeInsets.symmetric(horizontal: 23.99),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Your Recently Watched',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                  ],
                ),
              ),
            Divider(
              indent: 20,
              endIndent: 20,
            ),

            
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 200,
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        "No watched media",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final media = history[index];
                        final posterUrl = media.posterPath != null
                            ? "https://image.tmdb.org/t/p/w185${media.posterPath}"
                            : null;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailsScreen(movieId: media.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.all(5),
                            child: posterUrl != null
                                ? Image.network(posterUrl)
                                : const Icon(Icons.movie, color: Colors.white),
                          ),
                        );
                      },
                    ),
            ),

            //header for popular section
            Container(
              height: 28.01,
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              child: Row(
                children: <Widget>[
                  Text(
                    'Popular',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
            ),
            //Shows the scrollable list of movies
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 200,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Welcome_new.popMedia.length,
                  itemBuilder: (context, index) {
                    final selectedMovie = WelcomeUser.popMedia[index];
                    return GestureDetector(
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              Controller.mainImgURL +
                                  WelcomeUser.popMedia[index]['poster_path'] +
                                  Controller.apiKey,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsScreen(
                              movieId: selectedMovie['id'].toString(),
                            ),
                          ),
                        );
                      },
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
                children: <Widget>[
                  Text(
                    'Upcoming',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.40,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 20,
              endIndent: 20,
            ),
            //Scrollable list
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 200,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Welcome_new.upcomingMovies.length,
                  itemBuilder: (context, index) {
                    final selectedMovie = WelcomeUser.upcomingMovies[index];
                    return GestureDetector(
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              Controller.mainImgURL +
                                  Welcome_new.upcomingMovies[index]['poster_path'] +
                                  Controller.apiKey,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsScreen(
                              movieId: selectedMovie['id'].toString(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
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
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
