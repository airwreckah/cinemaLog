import '../models/media.dart';

class TrackerManager {
  static final TrackerManager _instance = TrackerManager._internal();

  factory TrackerManager() {
    return _instance;
  }

  TrackerManager._internal();

  final List<Media> _watchList = [];
  final List<Media> _watchHistory = [];

  void addToWatchList(Media media) {
    if (!_watchList.contains(media)) {
      _watchList.add(media);
    }
  }

  void removeFromWatchList(Media media) {
    _watchList.remove(media);
  }

  void markAsWatched(Media media) {
    if (_watchList.contains(media)) {
      _watchList.remove(media);
    }

    if (!_watchHistory.contains(media)) {
      _watchHistory.add(media);
    }
  }

  List<Media> getWatchList() {
    return List.unmodifiable(_watchList);
  }

  List<Media> getWatchHistory() {
    return List.unmodifiable(_watchHistory);
  }

  int getTotalWatched() {
    return _watchHistory.length;
  }

  void clearHistory() {
    _watchHistory.clear();
  }
}