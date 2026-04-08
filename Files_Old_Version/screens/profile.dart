import 'package:cinema_log/models/statistics.dart';
import 'package:cinema_log/services/tracker_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/media.dart';
import '../screens/login.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/search.dart';
import '../screens/movie.dart';
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

  List<Media> watchedMovies = [];

  int get totalMoviesWatched => stats.totalMoviesWatched;
  String get totalMoviesStr => totalMoviesWatched.toString();

  int get averageWatchedPerMonth => stats.averageWatchedPerMonth.round();
  String get averageWatchedPerMonthStr =>
      averageWatchedPerMonth.toString();

  String get favoriteGenre => stats.mostViewedGenre;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    await tracker.loadWatchHistory();
    setState(() {
      watchedMovies = tracker.getWatchHistory();
      stats = tracker.calculateStatistics(filter: statFilter);
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Login()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
    }
  }

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
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25),

            // Profile Icon
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: ShapeDecoration(
                color: Color(0xFFEADDFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Icon(Icons.person, size: 100.0),
            ),

            // Name
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                Profile.currentUser.fullName ?? "No Name",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Info
            Column(
              children: [
                Text("UID: ${Profile.currentUser.uid ?? "Loading..."}",
                    style: TextStyle(color: Colors.grey)),
                Text("Email: ${Profile.currentUser.email ?? "Loading..."}",
                    style: TextStyle(color: Colors.grey)),
                Text("Age: ${Profile.currentUser.age ?? "Loading..."}",
                    style: TextStyle(color: Colors.grey)),
                Text(
                    "Watchlists: ${Profile.currentUser.mediaLists.length}",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),

            // Stats
            Row(
              children: [
                Expanded(
                  child: statBox(
                      totalMoviesStr,
                      'Movies Watched',
                      Icons.local_movies,
                      [Color(0xFF4F39F6), Color(0xFF9810FA)]),
                ),
                Expanded(
                  child: statBox(
                      averageWatchedPerMonthStr,
                      'Average/Month',
                      Icons.access_time,
                      [Color(0xFF155DFC), Color(0xFF0092B8)]),
                ),
              ],
            ),

            infoBox("Favorite Genre", favoriteGenre),

            // 🔥 MOVIES WATCHED (FIXED NAVIGATION)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF101728),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Movies Watched",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  watchedMovies.isEmpty
                      ? Text("No movies watched yet",
                          style: TextStyle(color: Colors.white70))
                      : SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: watchedMovies.length,
                            itemBuilder: (context, index) {
                              final movie = watchedMovies[index];

                              return GestureDetector(
                                onTap: () {
                                  final movieMap = {
                                    'id': movie.id,
                                    'title': movie.title,
                                    'overview': movie.overview ?? "No description available'",
                                    'release_date': movie.year.toString(),
                                    'poster_path': movie.posterPath,
                                    'vote_average': 'N/A',
                                  };

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          Movie(movie: movieMap),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      EdgeInsets.only(right: 10),
                                  width: 120,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: movie.posterPath != null
                                            ? Image.network(
                                                "https://image.tmdb.org/t/p/w185${movie.posterPath}",
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey,
                                                child: Icon(Icons.movie,
                                                    color: Colors.white),
                                              ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        movie.title,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),

            settingsBox(),
          ],
        ),
      ),
      bottomNavigationBar: bottomNav(),
    );
  }

  // UI helpers (unchanged)
  Widget statBox(String value, String label, IconData icon, List<Color> colors) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget infoBox(String title, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF101728),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget settingsBox() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF101728),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
              title:
                  Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              trailing: Icon(Icons.logout, color: Colors.redAccent),
              onTap: signOut),
          Divider(color: Colors.white12),
          ListTile(
              title: Text('Delete Account',
                  style: TextStyle(color: Colors.redAccent)),
              trailing:
                  Icon(Icons.delete_forever, color: Colors.redAccent),
              onTap: deleteAccount),
        ],
      ),
    );
  }

  Widget bottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        Widget page;
        switch (index) {
          case 0:
            page = Login();
            break;
          case 1:
            page = Search();
            break;
          case 2:
            page = CustomListsScreen();
            break;
          default:
            page = Profile();
        }
        setState(() => _selectedIndex = index);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => page));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Lists'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}