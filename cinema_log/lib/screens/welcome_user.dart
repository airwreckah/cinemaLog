import 'package:cinema_log/screens/profile.dart';
import 'package:cinema_log/screens/search.dart';
import 'package:cinema_log/models/app_user.dart';
import 'package:cinema_log/services/tracker_manager.dart';
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

  Future<void> _loadAllData() async {
    await loadUserData();
    await tracker.loadWatchHistory();

    setState(() {
      history = tracker.getWatchHistory();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GradientText(
          'Cinema Log',
          style: const TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: const [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //show watch history if there is any
            if (!WelcomeUser.currentUser.watchHistoryNotEmpty())
              Container(
                height: 28.01,
                padding: const EdgeInsets.symmetric(horizontal: 23.99),
                child: const Row(
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
            const Divider(indent: 20, endIndent: 20),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 250,
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        'No watched media',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {...PointerDeviceKind.values},
                      ),
                      //needs to be listview.separated have space between the posers
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final media = history[index];
                          final poster_path = media.poster_path;
                          return GestureDetector(
                            child: Container(
                              width: 160,
                              padding: const EdgeInsets.all(5),
                              decoration: poster_path != null
                                  ? BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${Controller.mainImgURL}$poster_path',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : null,
                              child: poster_path == null
                                  ? const Icon(Icons.movie, color: Colors.white)
                                  : null,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => MovieDetailsScreen(
                                    mediaId: media.id.toString(),
                                    mediaType: media.type,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
            Container(
              height: 28.01,
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              child: const Row(
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
            const Divider(indent: 20, endIndent: 20),
            //popular movies list
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 250,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: Welcome_new.popMedia.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final selectedMovie = WelcomeUser.popMedia[index];
                    final poster_path = selectedMovie['poster_path'];

                    return GestureDetector(
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(5),
                        decoration: poster_path != null
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    '${Controller.mainImgURL}$poster_path',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                        child: poster_path == null
                            ? const Icon(Icons.movie, color: Colors.white)
                            : null,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsScreen(
                              mediaId: selectedMovie['id'].toString(),
                              mediaType: selectedMovie['media_type'] ?? 'movie',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            Container(
              height: 28.01,
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              child: const Row(
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
            const Divider(indent: 20, endIndent: 20),
            //Upcoming releases list
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 23.99),
              height: 250,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {...PointerDeviceKind.values},
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: Welcome_new.upcomingMovies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final selectedMovie = WelcomeUser.upcomingMovies[index];
                    final poster_path = selectedMovie['poster_path'];

                    return GestureDetector(
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(5),
                        decoration: poster_path != null
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    '${Controller.mainImgURL}$poster_path',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                        child: poster_path == null
                            ? const Icon(Icons.movie, color: Colors.white)
                            : null,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => MovieDetailsScreen(
                              mediaId: selectedMovie['id'].toString(),
                              mediaType: selectedMovie['media_type'] ?? 'movie',
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
              MaterialPageRoute(builder: (context) => const WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Search()),
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
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Lists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
