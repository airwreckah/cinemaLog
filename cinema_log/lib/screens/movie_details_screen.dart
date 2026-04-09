import 'package:cinema_log/screens/notes_screen.dart';
import 'package:flutter/material.dart';
import '../services/controller.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../models/media.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

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
        body: Center(child: CircularProgressIndicator()),
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
    final String releaseYear =
        releaseDate != 'Unknown' && releaseDate.length >= 4
            ? releaseDate.substring(0, 4)
            : 'Unknown';
    final String rating = _movieData!['vote_average']?.toString() ?? 'N/A';
    final String runtime = _movieData!['runtime'] != null
        ? '${_movieData!['runtime']} min'
        : 'Unknown';

    final media = Media(
      id: widget.movieId,
      title: title,
      type: 'movie',
      year: int.tryParse(releaseYear) ?? 0,
      genre: '',
      posterPath: posterPath,
    );

    final bool isWatched = _controller.isWatched(media.id);

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
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
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
                    const Icon(Icons.access_time, color: Colors.white70),
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
                // Mark as Watched button will add the movie to a "Watched" custom list. If the list doesn't exist, it will be created automatically. The user will also have the option to add the movie to any existing custom list they have created.
                TextButton(
                  onPressed: () async {
                    await _controller.markAsWatched(media);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            notesScreen(movieData: _movieData),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as watched')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF352c48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as Watched'),
                ),

                const SizedBox(width: 12),
                
                // Add to Custom List button will open a bottom sheet with a list of the user's custom lists. The user can select a list to add the movie to, or if they have no custom lists, they will be prompted to create one first.
                ElevatedButton(
                  onPressed: () async {
                    await _controller.loadCustomLists();
                    final lists = _controller.getCustomLists();

                    if (lists.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No custom lists available'),
                        ),
                      );
                      return;
                    }

                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return ListView(
                          children: lists.map((list) {
                            return ListTile(
                              title: Text(list.name),
                              onTap: () async {
                                await _controller.addMediaToCustomList(
                                  list.id,
                                  media,
                                );

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added to "${list.name}"'),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF352c48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Custom List'),
                ),
              ],
            ),

            // ============================
            //  TEMP TEST BUTTON (ADDED)
            // ============================

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () async {
                  final wasWatched = _controller.isWatched(media.id);

                  await _controller.toggleWatched(media);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasWatched
                            ? 'Removed from watched'
                            : 'Marked as watched',
                      ),
                    ),
                  );

                  setState(() {});
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isWatched
                      ? 'TEST: UNWATCH'
                      : 'TEST: WATCH',
                ),
              ),
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
