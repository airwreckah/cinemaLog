import 'package:flutter/material.dart';
import '../services/controller.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Cinema Log',
          style: TextStyle(
            color: Color(0xFF615FFF),
            fontWeight: FontWeight.bold,
          ),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (posterPath != null)
              Center(
                child: Image.network(
                  '${Controller.mainImgURL}/$posterPath',
                  height: 300,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // later: connect to TrackerManager
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1B2F),
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
                    backgroundColor: const Color(0xFF1B1B2F),
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
            const SizedBox(height: 10),
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