import '../models/media.dart';
import 'auth_service.dart';
import 'tracker_manager.dart';

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
}
