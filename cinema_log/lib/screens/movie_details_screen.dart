import 'package:flutter/material.dart';
import '../services/controller.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final Controller _controller = Controller();
  Map<String, dynamic>? _movieData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final movie = await _controller.fetchMovieById(widget.movieId);

      setState(() {
        _movieData = movie;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load movie details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _movieData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final title = _movieData!['title'] ?? 'Untitled';
    final overview = _movieData!['overview'] ?? 'No summary available.';
    final posterPath = _movieData!['poster_path'];
    final String releaseDate = _movieData!['release_date'] ?? 'Unknown';
    final String releaseYear = releaseDate != 'Unknown' && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : 'Unknown';
    final String rating = _movieData!['vote_average']?.toString() ?? 'N/A'; 
    final String runtime = _movieData!['runtime'] != null ? '${_movieData!['runtime']} min' : 'Unknown';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (posterPath != null)
              Center(
                child: Image.network(
                  '${Controller.mainImgURL}/$posterPath',
                  height: 300,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Row( children:[
                    const Icon(Icons.star, 
                    color: Colors.amber
                    ),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.circle, color: Colors.white70, size: 10),
                Text(
                  '$releaseYear',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Icon(Icons.circle, color: Colors.white70, size: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time
                    , color: Colors.white70
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // later: connect to TrackerManager
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF352c48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as Watched'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // later: connect to custom list logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF352c48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Custom List'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              overview,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}