import 'package:cinema_log/screens/notes_screen.dart';
import 'package:cinema_log/services/tracker_manager.dart';
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
  //provider information
  Map<String, dynamic>? _providerData;
  List<Map<String, dynamic>> freeProviders = [];
  List<Map<String, dynamic>> rentProviders = [];
  List<Map<String, dynamic>> buyProviders = [];
  List<Map<String, dynamic>> flatrateProviders = [];
  

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
      //fetch media 
      if (widget.mediaType == 'tv') {
        data = await _controller.fetchTvById(widget.mediaId);
        _providerData = await _controller.fetchProviderById(widget.mediaId, 'tv');
      } else {
        data = await _controller.fetchMovieById(widget.mediaId);
        _providerData = await _controller.fetchProviderById(widget.mediaId, 'movie');
      }
      //parse provider data
      _providerData?.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            if (item != null && item['provider_name'] != null) {
              final providerInfo = {
                'provider_name': item['provider_name'],
                'logo_path': item['logo_path'],
              };
              switch (key) {
                case 'free':
                  freeProviders.add(providerInfo);
                  break;
                case 'rent':
                  rentProviders.add(providerInfo);
                  break;
                case 'buy':
                  buyProviders.add(providerInfo);
                  break;
                case 'flatrate':
                  flatrateProviders.add(providerInfo);
                  break;
              }
            }
          }
        }
      });
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
  //parse title
  String _getTitle() {
    if (_mediaData == null) return 'Untitled';
    return _mediaData!['title'] ?? _mediaData!['name'] ?? 'Untitled';
  }
  //parse overview
  String _getOverview() {
    if (_mediaData == null) return 'No summary available.';
    return _mediaData!['overview'] ?? 'No summary available.';
  }
  //parse poster path
  String? _getPosterPath() {
    if (_mediaData == null) return null;
    return _mediaData!['poster_path'];
  }
  //parse release date
  String _getReleaseDate() {
    if (_mediaData == null) return 'Unknown';
    return _mediaData!['release_date'] ??
        _mediaData!['first_air_date'] ??
        'Unknown';
  }
  //parse release year
  String _getReleaseYear() {
    final releaseDate = _getReleaseDate();
    if (releaseDate != 'Unknown' && releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }
    return 'Unknown';
  }
  //parse rating
  String _getRating() {
    if (_mediaData == null) return 'N/A';
    final value = _mediaData!['vote_average'];
    return value != null ? value.toString() : 'N/A';
  }
  //parse runtime or seasons
  String _getRuntimeOrSeasons() {
    if (_mediaData == null) return 'Unknown';
    if (widget.mediaType.contains('tv')) {
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

  // Return ALL genres
  String _getGenre() {
    if (_mediaData == null) return '';

    final genres = _mediaData!['genres'];
    if (genres is List && genres.isNotEmpty) {
      return genres
          .map((g) => g['name'])
          .where((name) => name != null)
          .join(', ');
    }

    return '';
  }
  //fetch watch status 
  String _getWatchStatus() {
    return TrackerManager().getMediaStatus(widget.mediaId) ?? '';
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

    //get media details 
    final title = _getTitle();
    final overview = _getOverview();
    final poster_path = _getPosterPath();
    final releaseYear = _getReleaseYear();
    final rating = _getRating();
    final runtimeOrSeasons = _getRuntimeOrSeasons();
    final genre = _getGenre();

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
            const SizedBox(height: 10),
            // Genres Display
            if (genre.isNotEmpty)
              Text(
                genre,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
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
            Row( //details row
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( 
                  children: [
                    const Icon(Icons.star, color: Colors.amber), //rating
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
                const Icon(Icons.circle, color: Colors.white70, size: 10), //divider
                Text(     //release year
                  releaseYear,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Icon(Icons.circle, color: Colors.white70, size: 10), //divider
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70), //runtime or seasons
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
                    showModalBottomSheet( //set watch status menu
                      backgroundColor: Color(0xFF340090),
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (watchStatus != 'watched') //show mark as watched option if it hasn't been watched
                                ListTile(
                                  leading: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Mark as Watched',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'watched';
                                    });
                                    Navigator.pop(context);
                                    TrackerManager().markAsWatched(media);
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
                              if (watchStatus == 'watched') //show mark as unwatched option if it has been watched
                                ListTile(
                                  leading: const Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Mark as Unwatched',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await TrackerManager().setMediaStatus( 
                                      media,
                                      'unwatched',
                                    );
                                    if (context.mounted) {
                                        TrackerManager().markAsUnwatched(
                                        media,
                                      );
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
                              if (watchStatus != 'watching') //show mark as watching option if it isn't being watched
                                ListTile(
                                  leading: const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Mark as Watching',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'watching';
                                    });
                                    TrackerManager().setMediaStatus(media, 'watching');
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked as watching'),
                                      ),
                                    );
                                  },
                                ),
                              if (watchStatus == 'watching') //show mark as not watching option if it is being watched
                                ListTile(
                                  leading: const Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Mark as Not Watching',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'unwatched';
                                    });
                                    await TrackerManager().setMediaStatus(
                                      media,
                                      'unwatched',
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MovieDetailsScreen(
                                              mediaId: media.id,
                                              mediaType: media.type,
                                            ),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked as not watching'),
                                      ),
                                    );
                                  },
                                ),
                              if (watchStatus != 'want_to_watch') //show want to watch option if it isn't already marked as want to watch
                                ListTile(
                                  leading: const Icon(
                                    Icons.bookmark_border,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Want to Watch',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'want_to_watch';
                                    });
                                    Navigator.pop(context);
                                    TrackerManager().setMediaStatus(media, 'want_to_watch');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to want to watch'),
                                      ),
                                    );
                                  },
                                ),
                              if (watchStatus == 'want_to_watch') //show remove from want to watch option if it is marked as want to watch
                                ListTile(
                                  leading: const Icon(
                                    Icons.bookmark_border,
                                    color: Colors.white,
                                  ),
                                  title: const Text(
                                    'Remove from want to watch',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      watchStatus = 'unwatched';
                                    });
                                    Navigator.pop(context);

                                    await _controller.setMediaStatus(
                                      media,
                                      'unwatched',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Removed from want to watch',
                                        ),
                                      ),
                                    );
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
                      backgroundColor: Color(0xFF340090),
                      context: context,
                      builder: (_) {
                        return ListView(
                          children: lists.map((list) {
                            return ListTile(
                              title: Text(list.name, 
                                style: TextStyle(color: Colors.white),),
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
                  child: const Text(
                    'Add to Custom List',
                     style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
              const SizedBox(height: 16),
              ExpansionTile(
              title: Text(
                'Where to Watch',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Data provided by JustWatch', style: TextStyle(color: Colors.white54, fontSize: 12)),
              children: [if (freeProviders.isEmpty && rentProviders.isEmpty && buyProviders.isEmpty && flatrateProviders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No providers are available for this movie',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              else
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    freeProviders.isNotEmpty
                        ? 'Available for free on:'
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  freeProviders.isNotEmpty ?
                    Container(
                      height:75,
                      child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: freeProviders.length,
                      itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            Image.network(
                              '${Controller.mainImgURL}${freeProviders[index]['logo_path']}',
                              height: 50,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ) : Container(),
                  Text( rentProviders.isNotEmpty ? 'Available for rent on:' : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  rentProviders.isNotEmpty ?
                    Container(
                      height:75,
                      child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rentProviders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              Image.network(
                                '${Controller.mainImgURL}${rentProviders[index]['logo_path']}',
                                height: 50,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ) : Container(),
                  Text(
                    buyProviders.isNotEmpty
                        ? 'Available for purchase on:'
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  buyProviders.isNotEmpty ?
                    Container(
                      height:75,
                      child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: buyProviders.length,
                      itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            Image.network(
                              '${Controller.mainImgURL}${buyProviders[index]['logo_path']}',
                              height: 50,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ):Container(),
                  Text(
                    flatrateProviders.isNotEmpty
                        ? 'Available for streaming on:'
                        : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  flatrateProviders.isNotEmpty ?
                    Container(
                      height:75,
                      child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: flatrateProviders.length,
                      itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          children: [
                            Image.network(
                              '${Controller.mainImgURL}${flatrateProviders[index]['logo_path']}',
                              height: 50,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ):Container()
                ],
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
