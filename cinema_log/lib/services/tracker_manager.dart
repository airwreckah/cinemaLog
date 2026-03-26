import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/media.dart';
import '../models/statistics.dart';

enum StatisticsFilterType { month, year, lifetime }

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
}
