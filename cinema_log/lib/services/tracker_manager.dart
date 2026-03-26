import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
    if (!_watchList.contains(media) && !_watchHistory.contains(media)) {
      _watchList.add(media);
    }
  }

  void removeFromWatchList(Media media) {
    _watchList.remove(media);
  }

  void markAsWatched(Media media) {
    media.watched = true;
    media.watchDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_watchList.contains(media)) {
      _watchList.remove(media);
    }

    if (!_watchHistory.contains(media)) {
      _watchHistory.add(media);
    }

    // Save to Firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc('userId')
        .collection('watchHistory')
        .doc(media.id)
        .set(media.toMap());
  }

  void markAsUnwatched(Media media) {
    media.watched = false;
    media.watchDate = null;

    if (_watchHistory.contains(media)) {
      _watchHistory.remove(media);
    }

    if (!_watchList.contains(media)) {
      _watchList.add(media);
    }
  }

  bool isInWatchList(Media media) {
    return _watchList.contains(media);
  }

  bool isInWatchHistory(Media media) {
    return _watchHistory.contains(media);
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

  int getWatchListCount() {
    return _watchList.length;
  }

  double getCompletionRate() {
    final total = _watchList.length + _watchHistory.length;

    if (total == 0) {
      return 0.0;
    }

    return _watchHistory.length / total;
  }

  Media? getMediaById(String id) {
    for (var media in _watchList) {
      if (media.id == id) {
        return media;
      }
    }

    for (var media in _watchHistory) {
      if (media.id == id) {
        return media;
      }
    }

    return null;
  }

  void removeFromWatchListById(String id) {
    _watchList.removeWhere((media) => media.id == id);
  }

  void removeFromHistory(Media media) {
    _watchHistory.remove(media);
  }

  void removeFromHistoryById(String id) {
    _watchHistory.removeWhere((media) => media.id == id);
  }

  void clearHistory() {
    _watchHistory.clear();
  }

  void resetAll() {
    _watchList.clear();
    _watchHistory.clear();
  }
}
