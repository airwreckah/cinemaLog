import 'package:cinema_log/screens/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../models/media.dart';
import '../services/controller.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String mediaId;
  final String mediaType; // 'movie' or 'tv'

  const MovieDetailsScreen({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final Controller _controller = Controller();
  String watchStatus = 'unwatched';
  Map<String, dynamic>? _mediaData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    await _loadMediaDetails();
    await _loadWatchStatus();
  }

  Future<void> _loadWatchStatus() async {
    await _controller.loadWatchStatus();
    setState(() {
      watchStatus = _getWatchStatus();
    });
  }

  Future<void> _loadMediaDetails() async {
    try {
      Map<String, dynamic> data;

      if (widget.mediaType == 'tv') {
        data = await _controller.fetchTvById(widget.mediaId);
      } else {
        data = await _controller.fetchMovieById(widget.mediaId);
      }

      setState(() {
        _mediaData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load media details.';
        _isLoading = false;
      });
    }
  }

  String _getTitle() {
    if (_mediaData == null) return 'Untitled';
    return _mediaData!['title'] ?? _mediaData!['name'] ?? 'Untitled';
  }

  String _getOverview() {
    if (_mediaData == null) return 'No summary available.';
    return _mediaData!['overview'] ?? 'No summary available.';
  }

  String? _getPosterPath() {
    if (_mediaData == null) return null;
    return _mediaData!['poster_path'];
  }

  String _getReleaseDate() {
    if (_mediaData == null) return 'Unknown';
    return _mediaData!['release_date'] ??
        _mediaData!['first_air_date'] ??
        'Unknown';
  }

  String _getReleaseYear() {
    final releaseDate = _getReleaseDate();
    if (releaseDate != 'Unknown' && releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }
    return 'Unknown';
  }

  String _getRating() {
    if (_mediaData == null) return 'N/A';
    final value = _mediaData!['vote_average'];
    return value != null ? value.toString() : 'N/A';
  }

  String _getRuntimeOrSeasons() {
    if (_mediaData == null) return 'Unknown';

    if (widget.mediaType == 'tv') {
      final seasons = _mediaData!['number_of_seasons'];
      if (seasons != null) {
        return '$seasons season${seasons == 1 ? '' : 's'}';
      }
      return 'Unknown';
    }

    final runtime = _mediaData!['runtime'];
    if (runtime != null) {
      return '$runtime min';
    }
    return 'Unknown';
  }

  String _getGenre() {
    if (_mediaData == null) return '';

    final genres = _mediaData!['genres'];
    if (genres is List && genres.isNotEmpty) {
      return genres.first['name'] ?? '';
    }

    return '';
  }

  String _getWatchStatus() {
    if (_mediaData == null) return 'unwatched';
    return _controller.getMediaWatchStatus(widget.mediaId) ?? 'unwatched';
  }

  Media _buildMediaObject() {
    return Media(
      id: widget.mediaId,
      title: _getTitle(),
      type: widget.mediaType,
      year: int.tryParse(_getReleaseYear()) ?? 0,
      genre: _getGenre(),
      watchStatus: watchStatus,
      watchDate: null,
      poster_path: _getPosterPath(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty || _mediaData == null) {
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

    final title = _getTitle();
    final overview = _getOverview();
    final poster_path = _getPosterPath();
    final releaseYear = _getReleaseYear();
    final rating = _getRating();
    final runtimeOrSeasons = _getRuntimeOrSeasons();

    final media = _buildMediaObject();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
            if (poster_path != null)
              Center(
                child: Image.network(
                  '${Controller.mainImgURL}/$poster_path',
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
                    const SizedBox(width: 4),
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
                const Icon(Icons.circle, color: Colors.white70, size: 10),
                Text(
                  releaseYear,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Icon(Icons.circle, color: Colors.white70, size: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      runtimeOrSeasons,
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
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (watchStatus == 'unwatched')
                                ListTile(
                                  leading: const Icon(
                                    Icons.check_circle_outline,
                                  ),
                                  title: const Text('Mark as Watched'),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'watched';
                                    });
                                    Navigator.pop(context);
                                    await _controller.setMediaStatus(
                                      media,
                                      'watched',
                                    );
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              notesScreen(media: media),
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Marked as watched'),
                                        ),
                                      );
                                    }
                                  },
                                ),

                              if (watchStatus == 'watched')
                                ListTile(
                                  leading: const Icon(Icons.cancel_outlined),
                                  title: const Text('Mark as Unwatched'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _controller.setMediaStatus(
                                      media,
                                      'unwatched',
                                    );

                                    if (context.mounted) {
                                      _controller.markAsUnwatched(media);
                                      setState(() {
                                        watchStatus = 'unwatched';
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Marked as unwatched'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              if (watchStatus != 'watching')
                                ListTile(
                                  leading: const Icon(Icons.play_circle_outline),
                                  title: const Text('Mark as Watching'),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'watching';
                                    });
                                    await _controller.setMediaStatus(
                                      media,
                                      'watching',
                                    );
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked as watching'),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                ),
                              if (watchStatus != 'want_to_watch')
                                ListTile(
                                  leading: const Icon(Icons.bookmark_border),
                                  title: const Text('Want to Watch'),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'want_to_watch';
                                    });
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
                  child: const Text('Watch Status'),
                ),
                const SizedBox(width: 12),
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
