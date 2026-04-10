import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../services/tracker_manager.dart';
import '../models/statistics.dart';
import '../screens/movie_details_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  static late AppUser currentUser;
  static late TrackerManager trackerManager;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TrackerManager tracker = TrackerManager();

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
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
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

            const SizedBox(height: 10),

            // UID, Email, Age, Watchlists count
            Column(
              children: [
                Text(
                  "UID: ${Profile.currentUser.uid ?? 'Loading...'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Email: ${Profile.currentUser.email ?? 'Loading...'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Age: ${Profile.currentUser.age ?? 'Loading...'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "Watchlists: ${Profile.currentUser.mediaLists.length}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),
            
            // ===== Watch History =====
            const Text(
              "Watch History",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SizedBox(
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
                            ? "https://image.tmdb.org/t/p/w500${media.posterPath}"
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
                            width: 120,
                            margin: const EdgeInsets.only(left: 10),
                            child: posterUrl != null
                                ? Image.network(posterUrl, fit: BoxFit.cover)
                                : const Icon(Icons.movie, color: Colors.white),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 30),

            // ===== SETTINGS UI =====
            Container(
              margin: const EdgeInsets.all(10),
              width: 324,
              child: const Text(
                'SETTINGS',
                style: TextStyle(
                  color: Color(0xFF6A7282),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
