import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/main.dart';

class Movie extends StatefulWidget {
  final Map<String, dynamic> movie;

  const Movie({super.key, required this.movie});

  @override
  State<Movie> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<Movie> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    final String title = movie['title'] ?? 'Untitled';
    final String overview = movie['overview'] ?? 'No summary available.';
    final String releaseDate = movie['release_date'] ?? 'Unknown';
    final String posterPath = movie['poster_path'] ?? '';
    final String rating = movie['vote_average']?.toString() ?? 'N/A';

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
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Mark as Watched'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add to Custom List'),
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
      ),
    );
  }
}
