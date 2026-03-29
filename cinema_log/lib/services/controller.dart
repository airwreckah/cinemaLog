import 'package:cinema_log/screens/welcome.dart';

import '../models/media.dart';
import '../models/statistics.dart';
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

  //API CONSTANTS
  static String apiKey = '?api_key=e7d7f274b57eea7f8d7c9a51361d201d';
  static String mainURL = 'https://api.themoviedb.org/3/';
  static String mainImgURL = "https://image.tmdb.org/t/p/w185/";
  static String searchEndPnt = 'search/';
  static String popularEndPnt = 'trending/movie/day';

  Future<void> getPopularMedia() async {
    final url = Uri.parse(mainURL + popularEndPnt + apiKey);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Welcome.popMedia = data.values.toList()[1];
      print(Welcome.popMedia);
    } else {
      throw Exception('Failed to load popular movies.');
    }
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
}
