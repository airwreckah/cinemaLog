import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../services/controller.dart';
import '../screens/welcome_user.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/profile.dart';
import '../screens/movie_details_screen.dart';

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
  Map<int, String> _genreMap = {};
  String? _selectedGenre;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _controller.getMovieGenres();
      setState(() {
        _genreMap = genres;
      });
    } catch (e) {
      debugPrint('Failed to load genres: $e');
    }
  }

  Future<void> _searchMovies(String query) async {
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
      final results = await _controller.searchMovies(query);

      setState(() {
        _allResults = results;
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
      _searchMovies(value);
    });
  }

  void _applyGenreFilter() {
    if (_selectedGenre == null || _selectedGenre == 'All') {
      _filteredResults = List.from(_allResults);
      return;
    }

    _filteredResults = _allResults.where((movie) {
      final List genreIds = movie['genre_ids'] ?? [];

      final genreNames = genreIds
          .map((id) => _genreMap[id])
          .where((name) => name != null)
          .cast<String>()
          .toList();

      return genreNames.contains(_selectedGenre);
    }).toList();
  }

  List<String> _getGenreNames() {
    final genres = _genreMap.values.toList()..sort();
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => Profile()));
    }

    setState(() {
      _selectedIndex = index;
    });
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
                        'Start typing to search for movies.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredResults.length,
                      itemBuilder: (context, index) {
                        final movie = _filteredResults[index];
                        final title = movie['title'] ?? 'Untitled';
                        final releaseDate = movie['release_date'] ?? 'Unknown';
                        final posterPath = movie['poster_path'];

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
                                    movieId: movie['id'].toString(),
                                  ),
                                ),
                              );
                            },
                            leading: posterPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      '${Controller.mainImgURL}/$posterPath',
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.movie,
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
                              releaseDate,
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
