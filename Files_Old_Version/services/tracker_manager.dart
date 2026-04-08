import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/media.dart';
import '../models/statistics.dart';
import '../models/custom_list.dart';

enum StatisticsFilterType { month, year, lifetime }

class TrackerManager {
  static final TrackerManager _instance = TrackerManager._internal();

  factory TrackerManager() {
    return _instance;
  }

  TrackerManager._internal();

  final List<Media> _watchList = [];
  final List<Media> _watchHistory = [];
  final List<CustomList> _customLists = [];

  // ===================== WATCHLIST & HISTORY =====================

  void addToWatchList(Media media) {
    if (!_watchList.contains(media) && !_watchHistory.contains(media)) {
      _watchList.add(media);
    }
  }

  void removeFromWatchList(Media media) {
    _watchList.remove(media);
  }

  // Mark as watched and save to Firebase
  Future<void> markAsWatched(Media media) async {
    media.watched = true;
    media.watchDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (_watchList.contains(media)) _watchList.remove(media);

    if (!_watchHistory.any((m) => m.id == media.id)) {
      _watchHistory.add(media);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchHistory')
          .doc(media.id)
          .set(media.toMap());
    }
  }

  // Mark as unwatched and remove from Firebase
  Future<void> markAsUnwatched(Media media) async {
    media.watched = false;
    media.watchDate = null;

    _watchHistory.removeWhere((m) => m.id == media.id);

    if (!_watchList.contains(media)) _watchList.add(media);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchHistory')
          .doc(media.id)
          .delete();
    }
  }

  bool isInWatchList(Media media) => _watchList.contains(media);
  bool isInWatchHistory(Media media) => _watchHistory.contains(media);

  List<Media> getWatchList() => List.unmodifiable(_watchList);
  List<Media> getWatchHistory() => List.unmodifiable(_watchHistory);

  int getTotalWatched() => _watchHistory.length;
  int getWatchListCount() => _watchList.length;

  double getCompletionRate() {
    final total = _watchList.length + _watchHistory.length;
    return total == 0 ? 0.0 : _watchHistory.length / total;
  }

Media? getMediaById(String id) {
  try {
    return _watchList.firstWhere((media) => media.id == id);
  } catch (_) {}

  try {
    return _watchHistory.firstWhere((media) => media.id == id);
  } catch (_) {}

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

  // ===================== LOAD WATCH HISTORY =====================

  Future<void> loadWatchHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchHistory')
          .get();

      _watchHistory.clear();

      for (var doc in snapshot.docs) {
        final media = Media.fromMap(doc.data());
        media.watched = true;
        _watchHistory.add(media);
      }

      // Remove already watched movies from watchlist
      _watchList.removeWhere(
          (movie) => _watchHistory.any((watched) => watched.id == movie.id));
    } catch (e) {
      print('Error loading watch history: $e');
    }
  }

  // ===================== STATISTICS =====================

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
      if (media.watchDate == null) return false;
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  String _getMostFrequentKey(Map<String, int> counts) {
    if (counts.isEmpty) return 'N/A';
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
    if (monthlyCounts.isEmpty) return 0.0;
    final total = monthlyCounts.values.fold(0, (sum, count) => sum + count);
    return total / monthlyCounts.length;
  }

  // ===================== CUSTOM LISTS =====================

  List<CustomList> getCustomLists() => List.unmodifiable(_customLists);

  void createCustomList(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final alreadyExists = _customLists.any(
      (list) => list.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (!alreadyExists) {
      _customLists.add(
        CustomList(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: trimmedName,
        ),
      );
    }
  }

  void deleteCustomList(String id) {
    _customLists.removeWhere((list) => list.id == id);
  }

  CustomList? getCustomListById(String id) {
    for (final list in _customLists) {
      if (list.id == id) return list;
    }
    return null;
  }

  void renameCustomList(String id, String newName) {
    final list = getCustomListById(id);
    if (list != null && newName.trim().isNotEmpty) {
      list.name = newName.trim();
    }
  }

  void addMediaToCustomList(String listId, Media media) {
    final list = getCustomListById(listId);
    if (list != null) list.addMedia(media);
  }

  void removeMediaFromCustomList(String listId, Media media) {
    final list = getCustomListById(listId);
    if (list != null) list.removeMedia(media);
  }
}