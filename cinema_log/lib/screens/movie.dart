import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/main.dart';
import '../services/controller.dart';
import '../models/media.dart';
import 'welcome_user.dart';
import 'profile.dart';
import 'search.dart';
import '../screens/custom_lists_screen.dart';

class Movie extends StatefulWidget {
  final Map<String, dynamic> movie;

  const Movie({super.key, required this.movie});

  @override
  State<Movie> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<Movie> {
  int _selectedIndex = 0;

  final Controller _controller = Controller();

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isWatched = _controller.isWatched(movie['id'].toString());

    final String title = movie['title'] ?? 'Untitled';
    final String overview = movie['overview'] ?? 'No summary available.';
    final String releaseDate = movie['release_date'] ?? 'Unknown';
    final String posterPath = movie['poster_path'] ?? '';
    final String rating = movie['vote_average']?.toString() ?? 'N/A';
    final String releaseYear = releaseDate != 'Unknown' && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : 'Unknown';
    final String runtime = movie['runtime'] != null ? '${movie['runtime']} min' : 'Unknown';

    final String imageUrl = posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: GradientText(
          'Cinema Log',
          style: const TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)], //header title
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.bold,
              ),
              
            ),
            const SizedBox(height: 16),

            Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: Text('Poster image not available'),
                          ),
                        );
                      },
                    )
                  : const SizedBox(
                      height: 300,
                      child: Center(child: Text('Poster image not available')),
                    ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$releaseYear',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  runtime,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                   style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF352c48),
                    ),
                  onPressed: _toggleWatched,
                  child: Text(
                    isWatched ? 'Already Watched ✓' : 'Mark as Watched',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    ),
                 ),
                const SizedBox(width: 16),
                TextButton(
                   style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF352c48),
                    ),
                  onPressed: _showAddToCustomListDialog,
                  child: const Text('Add to Custom List',
                    style: TextStyle(
                    color: Colors.white,
                    ),
                    ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              overview,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.normal,
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
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
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

  void _showAddToCustomListDialog() {
    final customLists = _controller.getCustomLists();

    if (customLists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a custom list')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Custom List'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: customLists.length,
              itemBuilder: (context, index) {
                final customList = customLists[index];

                return ListTile(
                  title: Text(customList.name),
                  subtitle: Text('${customList.items.length} movies'),
                  onTap: () {
                    final movie = widget.movie;

                    final media = Media(
                      id: movie['id'].toString(),
                      title: movie['title'] ?? 'Untitled',
                      type: 'movie',
                      year:
                          movie['release_date'] != null &&
                              movie['release_date'].toString().length >= 4
                          ? int.tryParse(
                                  movie['release_date'].toString().substring(
                                    0,
                                    4,
                                  ),
                                ) ??
                                0
                          : 0,
                      genre: 'Unknown',
                    );

                    _controller.addMediaToCustomList(customList.id, media);
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to ${customList.name}')),
                    );

                    setState(() {});
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleWatched() {
    final movieData = widget.movie;

    final media = Media(
      id: movieData['id'].toString(),
      title: movieData['title'] ?? 'Untitled',
      type: 'movie',
      year:
          movieData['release_date'] != null &&
              movieData['release_date'].toString().length >= 4
          ? int.tryParse(
                  movieData['release_date'].toString().substring(0, 4),
                ) ??
                0
          : 0,
      genre: 'Unknown',
      posterPath: movieData['poster_path'],
    );

    final isWatched = _controller.isWatched(media.id);

    _controller.toggleWatched(media);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWatched
              ? '${media.title} removed from watched list'
              : '${media.title} marked as watched',
        ),
      ),
    );

    setState(() {});
  }

  
}
