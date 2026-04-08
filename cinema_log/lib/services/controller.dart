import 'dart:ffi';
import 'dart:math';

import 'package:cinema_log/screens/welcome_new.dart';
import 'package:cinema_log/screens/welcome_user.dart';

import '../models/media.dart';
import '../models/statistics.dart';
import '../models/custom_list.dart';
import '../env/env.dart';
import 'authService.dart';
import 'tracker_manager.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';

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

  Future<String> readEnv({String path = 'cinema_log\.env'}) async {
    final file = File(path);
    final lines = await file.readAsLines();
    return lines.isEmpty ? '' : lines.first.trim();
  }

  static String apiKey = '';
  Future<void> init() async {
    apiKey = Env.apiKey;
  }

  //API CONSTANTS

  static const String mainURL = 'api.themoviedb.org';
  static const String mainImgURL = "https://image.tmdb.org/t/p/w185";
  static const String smallImgURL = "https://image.tmdb.org/t/p/w92";
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
    final url = Uri.https(mainURL, '/3/genre/movie/list', {'api_key': apiKey});

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

  Future<Map<String, dynamic>> fetchMovieById(String movieId) async {
    final url = Uri.https(mainURL, '$movieEndPnt$movieId', {
      'api_key': apiKey,
      'language': 'en-US',
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch movie details.');
    }
  }

  List<CustomList> getCustomLists() {
    return _trackerManager.getCustomLists();
  }

  Future<void> createCustomList(String name) async {
    await _trackerManager.createCustomList(name);
  }

  Future<void> loadCustomLists() async {
    await _trackerManager.loadCustomLists();
  }

  Future<void> deleteCustomList(String id) async {
    await _trackerManager.deleteCustomList(id);
  }

  Future<void> renameCustomList(String id, String newName) async {
    await _trackerManager.renameCustomList(id, newName);
  }

  Future<void> addMediaToCustomList(String listId, Media media) async {
    await _trackerManager.addMediaToCustomList(listId, media);
  }

  Future<void> removeMediaFromCustomList(String listId, Media media) async {
    await _trackerManager.removeMediaFromCustomList(listId, media);
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
