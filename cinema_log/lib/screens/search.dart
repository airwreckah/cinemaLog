import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/screens/custom_lists_screen.dart';
import 'package:cinema_log/screens/profile.dart';
import 'package:cinema_log/screens/movie_details_screen.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  final Controller _controller = Controller();
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 1;
  bool _isLoading = false;

  List<dynamic> _allResults = [];
  List<dynamic> _filteredResults = [];

  Map<int, String> _movieGenreMap = {};
  Map<int, String> _tvGenreMap = {};
  String? _selectedGenre;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final movieGenres = await _controller.getMovieGenres();
      final tvGenres = await _controller.getTvGenres();

      setState(() {
        _movieGenreMap = movieGenres;
        _tvGenreMap = tvGenres;
      });
    } catch (e) {
      debugPrint('Failed to load genres: $e');
    }
  }

  Future<void> _searchMedia(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _allResults = [];
        _filteredResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _controller.searchMedia(query);

      final filtered = results.where((item) {
        final mediaType = item['media_type'];
        return mediaType == 'movie' || mediaType == 'tv';
      }).toList();

      filtered.sort((a, b) {
        final double popA = (a['popularity'] ?? 0).toDouble();
        final double popB = (b['popularity'] ?? 0).toDouble();
        return popB.compareTo(popA);
      });

      setState(() {
        _allResults = filtered;
        _applyGenreFilter();
      });
    } catch (e) {
      debugPrint('Search failed: $e');
      setState(() {
        _allResults = [];
        _filteredResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchMedia(value);
    });
  }

  void _applyGenreFilter() {
    if (_selectedGenre == null || _selectedGenre == 'All') {
      _filteredResults = List.from(_allResults);
    } else {
      _filteredResults = _allResults.where((media) {
        final mediaType = media['media_type'];
        final List genreIds = media['genre_ids'] ?? [];

        final genreMap = mediaType == 'tv' ? _tvGenreMap : _movieGenreMap;

        final genreNames = genreIds
            .map((id) => genreMap[id])
            .where((name) => name != null)
            .cast<String>()
            .toList();

        return genreNames.contains(_selectedGenre);
      }).toList();
    }

    _filteredResults.sort((a, b) {
      final double popA = (a['popularity'] ?? 0).toDouble();
      final double popB = (b['popularity'] ?? 0).toDouble();
      return popB.compareTo(popA);
    });
  }

  List<String> _getGenreNames() {
    final allGenres = <String>{};
    allGenres.addAll(_movieGenreMap.values);
    allGenres.addAll(_tvGenreMap.values);

    final genres = allGenres.toList()..sort();
    return ['All', ...genres];
  }

  void _showGenreFilter() {
    final genres = _getGenreNames();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1228),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: genres.map((genre) {
            return ListTile(
              title: Text(genre, style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _selectedGenre = genre == 'All' ? null : genre;
                  _applyGenreFilter();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WelcomeUser()));
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Search()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CustomListsScreen()),
      );
    } else if (index == 3) {
      Profile.currentUser = WelcomeUser.currentUser;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Profile()),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle(dynamic media) {
    return media['title'] ?? media['name'] ?? 'Untitled';
  }

  String _getReleaseDate(dynamic media) {
    return media['release_date'] ?? media['first_air_date'] ?? 'Unknown';
  }

  String _getMediaTypeLabel(dynamic media) {
    return media['media_type'] == 'tv' ? 'TV Show' : 'Movie';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1228),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1A2A4A)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search movies, TV, genres...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white70),
                    onPressed: _showGenreFilter,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedGenre != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(_selectedGenre!),
                  backgroundColor: const Color(0xFF1B2A52),
                  labelStyle: const TextStyle(color: Colors.white),
                  deleteIconColor: Colors.white,
                  onDeleted: () {
                    setState(() {
                      _selectedGenre = null;
                      _applyGenreFilter();
                    });
                  },
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Start typing to search for movies or TV shows.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredResults.length,
                      itemBuilder: (context, index) {
                        final media = _filteredResults[index];
                        final title = _getTitle(media);
                        final releaseDate = _getReleaseDate(media);
                        final mediaTypeLabel = _getMediaTypeLabel(media);
                        final poster_path = media['poster_path'];

                        return Card(
                          color: const Color(0xFF0A1228),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailsScreen(
                                    mediaId: media['id'].toString(),
                                    mediaType: media['media_type'] ?? 'movie',
                                  ),
                                ),
                              );
                            },
                            leading: poster_path != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      '${Controller.mainImgURL}/$poster_path',
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    media['media_type'] == 'tv'
                                        ? Icons.tv
                                        : Icons.movie,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '$mediaTypeLabel • $releaseDate',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF000814),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF615FFF),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
