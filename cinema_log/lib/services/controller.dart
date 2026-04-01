import 'dart:ffi';

import 'package:cinema_log/screens/welcome_new.dart';
import 'package:cinema_log/screens/welcome_user.dart';

import '../models/media.dart';
import '../models/statistics.dart';
import '../models/custom_list.dart';
import 'authService.dart';
import 'tracker_manager.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Controller {
  final AuthService _authService = AuthService();
  final TrackerManager _trackerManager = TrackerManager();

  // AUTHENTICATION
  Future<bool> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    int age,
  ) async {
    try {
      await _authService.signUp(email, password, name, age.toString());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // TRACKER

  void addToWatchList(Media media) {
    _trackerManager.addToWatchList(media);
  }

  void removeFromWatchList(Media media) {
    _trackerManager.removeFromWatchList(media);
  }

  void markAsWatched(Media media) {
    _trackerManager.markAsWatched(media);
  }

  void markAsUnwatched(Media media) {
    _trackerManager.markAsUnwatched(media);
  }

  List<Media> getWatchList() {
    return _trackerManager.getWatchList();
  }

  List<Media> getWatchHistory() {
    return _trackerManager.getWatchHistory();
  }

  int getTotalWatched() {
    return _trackerManager.getTotalWatched();
  }

  int getWatchListCount() {
    return _trackerManager.getWatchListCount();
  }

  double getCompletionRate() {
    return _trackerManager.getCompletionRate();
  }

  Media? getMediaById(String id) {
    return _trackerManager.getMediaById(id);
  }

  void removeFromWatchListById(String id) {
    _trackerManager.removeFromWatchListById(id);
  }

  void removeFromHistory(Media media) {
    _trackerManager.removeFromHistory(media);
  }

  void removeFromHistoryById(String id) {
    _trackerManager.removeFromHistoryById(id);
  }

  void clearHistory() {
    _trackerManager.clearHistory();
  }

  void resetAll() {
    _trackerManager.resetAll();
  }

  Statistics calculateStatistics({
    required StatisticsFilterType filterType,
    int? month,
    int? year,
  }) {
    return _trackerManager.calculateStatistics(
      filter: filterType,
      month: month,
      year: year,
    );
  }

  //API CONSTANTS
  static const String apiKey = 'e7d7f274b57eea7f8d7c9a51361d201d';
  static const String mainURL = 'api.themoviedb.org';
  static const String mainImgURL = "https://image.tmdb.org/t/p/w185";
  static const String searchEndPnt = '/3/search/keyword';
  static const String popularEndPnt = '/3/trending/movie/day';
  static const String upcomingEndPnt = '/3/movie/upcoming';
  static const String searchMovieEndPnt = '/3/search/movie';
  static const String idEndPnt = '/3/find/external_id';
  static const String movieEndPnt = '/3/movie/';

  Future<void> getPopularMedia() async {
    final url = Uri.https(mainURL, popularEndPnt, {'api_key': apiKey});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Welcome_new.popMedia = data['results'] ?? [];
      WelcomeUser.popMedia = data['results'] ?? [];
    } else {
      throw Exception('Failed to load popular movies.');
    }
  }

  Future<void> getUpcomingMovies() async {
    final url = Uri.https(mainURL, upcomingEndPnt, {'api_key': apiKey});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Welcome_new.upcomingMovies = data['results'] ?? [];
      WelcomeUser.upcomingMovies = data['results'] ?? [];
    } else {
      throw Exception('Failed to load upcoming movies.');
    }
  }

  Future<List<dynamic>> searchMovies(String query) async {
    final url = Uri.https(mainURL, searchMovieEndPnt, {
      'api_key': apiKey,
      'query': query,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'] ?? [];
    } else {
      throw Exception('Failed to search movies.');
    }
  }

  // Genre
  Future<Map<int, String>> getMovieGenres() async {
  final url = Uri.https(mainURL, '/3/genre/movie/list', {
    'api_key': apiKey,
  });

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List genres = data['genres'] ?? [];

    return {
      for (var genre in genres) genre['id'] as int: genre['name'] as String,
    };
  } else {
    throw Exception('Failed to load genres.');
  }
}

  Future<List<dynamic>> fetchMovieByID(String query) async {
    final url = Uri.https(mainURL, movieEndPnt, {
      'movie_id': query,
      'language': 'en-US',
      'api_key': apiKey,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final movie = await data as Future<List<dynamic>>;
      return movie;
    } else {
      throw Exception('Failed to search movies.');
    }
  }

  List<CustomList> getCustomLists() {
    return _trackerManager.getCustomLists();
  }

  void createCustomList(String name) {
    _trackerManager.createCustomList(name);
  }

  void deleteCustomList(String id) {
    _trackerManager.deleteCustomList(id);
  }

  void renameCustomList(String id, String newName) {
    _trackerManager.renameCustomList(id, newName);
  }

  void addMediaToCustomList(String listId, Media media) {
    _trackerManager.addMediaToCustomList(listId, media);
  }

  void removeMediaFromCustomList(String listId, Media media) {
    _trackerManager.removeMediaFromCustomList(listId, media);
  }

  CustomList? getCustomListById(String id) {
    return _trackerManager.getCustomListById(id);
  }

  bool isWatched(String id) {
    return _trackerManager.getWatchHistory().any((m) => m.id == id);
  }

  void toggleWatched(Media media) {
    final isWatched = _trackerManager.getWatchHistory().any(
      (m) => m.id == media.id,
    );

    if (isWatched) {
      _trackerManager.removeFromHistory(media);
    } else {
      _trackerManager.markAsWatched(media);
    }
  }
}
