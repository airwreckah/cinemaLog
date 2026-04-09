import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/media.dart';
import '../models/statistics.dart';
import '../models/custom_list.dart';
import '../env/env.dart';

enum StatisticsFilterType { month, year, lifetime }

class TrackerManager {
  static final TrackerManager _instance = TrackerManager._internal();

  factory TrackerManager() {
    return _instance;
  }

  TrackerManager._internal();
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  final List<Media> _watchList = [];
  final List<Media> _watchHistory = [];
  final List<CustomList> _customLists = [];

  void addToWatchList(Media media) {
    if (!_watchList.contains(media) && !_watchHistory.contains(media)) {
      _watchList.add(media);
    }
  }

  void removeFromWatchList(Media media) {
    _watchList.remove(media);
  }

  Future<void> markAsWatched(Media media) async {
    media.watched = true;
    media.watchDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_watchList.contains(media)) {
      _watchList.remove(media);
    }

    if (!_watchHistory.any((m) => m.id == media.id)) {
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
    _watchHistory.removeWhere((m) => m.id == media.id);
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
    _customLists.clear();
  }

  Statistics calculateStatistics({
    required StatisticsFilterType filter,
    int? month,
    int? year,
  }) {
    final filteredHistory = _getFilteredHistory(
      filter: filter,
      month: month,
      year: year,
    );

    int totalMoviesWatched = 0;
    int totalTvShowsWatched = 0;

    final Map<String, int> moviesWatchedPerMonth = {};
    final Map<String, int> genreCounts = {};

    for (final media in filteredHistory) {
      final mediaType = media.type.toLowerCase().trim();

      if (mediaType == 'movie') {
        totalMoviesWatched++;

        if (media.watchDate != null) {
          final monthKey = _formatMonthKey(media.watchDate!);
          moviesWatchedPerMonth[monthKey] =
              (moviesWatchedPerMonth[monthKey] ?? 0) + 1;
        }
      } else if (mediaType == 'tv show') {
        totalTvShowsWatched++;
      }

      final genreKey = media.genre.trim();
      if (genreKey.isNotEmpty) {
        genreCounts[genreKey] = (genreCounts[genreKey] ?? 0) + 1;
      }
    }

    final totalItemsWatched = filteredHistory.length;
    final mostViewedGenre = _getMostFrequentKey(genreCounts);
    final averageWatchedPerMonth = _calculateAverageWatchedPerMonth(
      moviesWatchedPerMonth,
    );

    return Statistics(
      totalMoviesWatched: totalMoviesWatched,
      totalTvShowsWatched: totalTvShowsWatched,
      totalItemsWatched: totalItemsWatched,
      moviesWatchedPerMonth: moviesWatchedPerMonth,
      genreCounts: genreCounts,
      mostViewedGenre: mostViewedGenre,
      averageWatchedPerMonth: averageWatchedPerMonth,
    );
  }

  List<Media> _getFilteredHistory({
    required StatisticsFilterType filter,
    int? month,
    int? year,
  }) {
    final now = DateTime.now();

    return _watchHistory.where((media) {
      if (media.watchDate == null) {
        return false;
      }

      final watchDate = media.watchDate!;

      switch (filter) {
        case StatisticsFilterType.month:
          final targetMonth = month ?? now.month;
          final targetYear = year ?? now.year;
          return watchDate.month == targetMonth && watchDate.year == targetYear;

        case StatisticsFilterType.year:
          final targetYear = year ?? now.year;
          return watchDate.year == targetYear;

        case StatisticsFilterType.lifetime:
          return true;
      }
    }).toList();
  }

  String _formatMonthKey(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String _getMostFrequentKey(Map<String, int> counts) {
    if (counts.isEmpty) {
      return 'N/A';
    }
    String topKey = counts.keys.first;
    int topValue = counts[topKey]!;

    counts.forEach((key, value) {
      if (value > topValue) {
        topKey = key;
        topValue = value;
      }
    });

    return topKey;
  }

  double _calculateAverageWatchedPerMonth(Map<String, int> monthlyCounts) {
    if (monthlyCounts.isEmpty) {
      return 0.0;
    }

    final total = monthlyCounts.values.fold(0, (sum, count) => sum + count);
    return total / monthlyCounts.length;
  }

  List<CustomList> getCustomLists() {
    return List.unmodifiable(_customLists);
  }

  Future<void> createCustomList(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    final alreadyExists = _customLists.any(
      (list) => list.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (alreadyExists) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final list = CustomList(id: id, name: trimmedName, items: []);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('customLists')
        .doc(id)
        .set(list.toMap());

    _customLists.add(list);
  }

  Future<void> loadCustomLists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('customLists')
        .get();

    _customLists.clear();

    for (final doc in snapshot.docs) {
      _customLists.add(CustomList.fromMap(doc.data()));
    }
  }

  Future<void> deleteCustomList(String id) async {
    _customLists.removeWhere((list) => list.id == id);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('customLists')
        .doc(id)
        .delete();
  }

  CustomList? getCustomListById(String id) {
    for (final list in _customLists) {
      if (list.id == id) {
        return list;
      }
    }
    return null;
  }

  Future<void> renameCustomList(String id, String newName) async {
    final list = getCustomListById(id);
    if (list != null && newName.trim().isNotEmpty) {
      list.name = newName.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('customLists')
          .doc(id)
          .update({'name': list.name});
    }
  }

  Future<void> addMediaToCustomList(String listId, Media media) async {
    final list = getCustomListById(listId);

    if (list != null) {
      list.addMedia(media);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('customLists')
          .doc(listId)
          .update({'items': list.items.map((e) => e.toMap()).toList()});
    }
  }

  Future<void> removeMediaFromCustomList(String listId, Media media) async {
    final list = getCustomListById(listId);
    if (list != null) {
      list.removeMedia(media);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('customLists')
          .doc(listId)
          .update({'items': list.items.map((e) => e.toMap()).toList()});
    }
  }
}
