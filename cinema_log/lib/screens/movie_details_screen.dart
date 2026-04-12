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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.add_circle_outline),
                                title: const Text('Quick Watch'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _controller.setMediaStatus(
                                    media,
                                    'watched',
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked as watched'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.check_circle_outline_outlined),
                                title: const Text('Watched'),
                                onTap: () async {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            notesScreen(movieData: _movieData, media: media,),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.play_circle_outline),
                                title: const Text('Watching'),
                                onTap: () async {
                                  await _controller.setMediaStatus(
                                    media,
                                    'watching',
                                  );
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to watching'),
                                    ),
                                  );

                                  setState(() {});
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.bookmark_border),
                                title: const Text('Want to Watch'),
                                onTap: () async {
                                  Navigator.pop(context);

                                  await _controller.setMediaStatus(
                                    media,
                                    'want_to_watch',
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to want to watch'),
                                    ),
                                  );

                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF352c48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Set Watch Status'),
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
