import 'package:cinema_log/screens/notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ffi';
import '../models/media.dart';
import '../models/statistics.dart';
import '../models/custom_list.dart';

enum StatisticsFilterType { week, month, year, lifetime }

class TrackerManager {
  static final TrackerManager _instance = TrackerManager._internal();

  factory TrackerManager() {
    return _instance;
  }

  TrackerManager._internal();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  final List<Media> _watchList = [];
  final List<Media> _currentlyWatching = [];
  final List<Media> _watchHistory = [];
  final List<CustomList> _customLists = [];
  final List<Media> _watchStatus = [];

  // ================= WATCHLIST =================

  void addToWatchList(Media media) {
    if (!_watchList.contains(media) &&
        !_watchHistory.any((m) => m.id == media.id)) {
      _watchList.add(media);
    }
  }

  void removeFromWatchList(Media media) {
    _watchList.removeWhere((m) => m.id == media.id);
  }

  // ================= WATCH HISTORY =================

  Future<void> markAsWatched(Media media) async {
    if (_uid == null) return;

    media.watched = true;
    media.watchDate = media.watchDate ?? DateTime.now();

    _watchList.removeWhere((m) => m.id == media.id);

    if (!_watchHistory.any((m) => m.id == media.id)) {
      _watchHistory.add(media);
      setMediaStatus(media, 'watched');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchHistory')
        .doc(media.id)
        .set(media.toMap());
  }

  // ================= WANT TO WATCH =================

  void addToCurrentlyWatching(Media media) {
    if (!_currentlyWatching.any((m) => m.id == media.id)) {
      _currentlyWatching.add(media);
    }
  }

  void removeFromCurrentlyWatching(Media media) {
    _currentlyWatching.removeWhere((m) => m.id == media.id);
  }

  List<Media> getCurrentlyWatching() => List.unmodifiable(_currentlyWatching);

  Future<void> markAsUnwatched(Media media) async {
    if (_uid == null) return;

    media.watched = false;
    media.watchDate = null;

    _watchHistory.removeWhere((m) => m.id == media.id);

    if (!_watchList.any((m) => m.id == media.id)) {
      _watchList.add(media);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchHistory')
        .doc(media.id)
        .delete();
  }

  Future<void> loadWatchHistory() async {
    if (_uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchHistory')
        .get();

    _watchHistory.clear();

    for (final doc in snapshot.docs) {
      _watchHistory.add(Media.fromMap(doc.data()));
    }
  }

  // ================= GETTERS =================

  bool isInWatchList(Media media) {
    return _watchList.any((m) => m.id == media.id);
  }

  bool isInWatchHistory(Media media) {
    return _watchHistory.any((m) => m.id == media.id);
  }

  List<Media> getWatchList() => List.unmodifiable(_watchList);

  List<Media> getWatchHistory() => List.unmodifiable(_watchHistory);

  int getTotalWatched() => _watchHistory.length;

  int getWatchListCount() => _watchList.length;

  double getCompletionRate() {
    final total = _watchList.length + _watchHistory.length;
    return total == 0 ? 0.0 : _watchHistory.length / total;
  }

  Media? getMediaById(String id) {
    for (var m in _watchList) {
      if (m.id == id) return m;
    }
    for (var m in _watchHistory) {
      if (m.id == id) return m;
    }
    return null;
  }

  void removeFromWatchListById(String id) {
    _watchList.removeWhere((m) => m.id == id);
  }

  void removeFromHistoryById(String id) {
    _watchHistory.removeWhere((m) => m.id == id);
  }

  void removeFromHistory(Media media) {
    _watchHistory.removeWhere((m) => m.id == media.id);
  }

  void clearHistory() => _watchHistory.clear();

  void resetAll() {
    _watchList.clear();
    _watchHistory.clear();
    _currentlyWatching.clear();
    _customLists.clear();
  }

  // ================= STATS =================

  Map<String, double> getMoviesWatchedByMonth(List<Media> history) {
    final Map<String, double> countsPerMonth = {};
    DateTime? watchedDay;

    for (final media in history) {
      if (media.type.toLowerCase() == 'movie' && media.watchDate != null) {
        watchedDay = media.watchDate;
        final key = _formatMonthKey(media.watchDate!);
        countsPerMonth[key] = (countsPerMonth[key] ?? 0) + 1;
      }
    }

    return countsPerMonth;
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

    int movies = 0;
    int tv = 0;

    final Map<String, int> monthly = {};
    final Map<String, double> genres = {};

    for (final media in filteredHistory) {
      final type = media.type.toLowerCase();

      if (type == 'movie') {
        movies++;
        if (media.watchDate != null) {
          final key = _formatMonthKey(media.watchDate!);
          monthly[key] = (monthly[key] ?? 0) + 1;
        }
      } else if (type.contains('tv')) {
        tv++;
      }

      if (media.genre.isNotEmpty) {
        genres[media.genre] = (genres[media.genre] ?? 0) + 1;
      }
    }

    return Statistics(
      totalMoviesWatched: movies,
      totalTvShowsWatched: tv,
      totalItemsWatched: filteredHistory.length,
      moviesWatchedPerMonth: monthly,
      genreCounts: genres,
      mostViewedGenre: _getMostFrequentKey(genres),
      averageWatchedPerMonth: _calculateAverageWatchedPerMonth(monthly),
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

      final d = media.watchDate!;

      switch (filter) {
        case StatisticsFilterType.week:
          final weekAgo = now.subtract(Duration(days: 7));
          return d.isAfter(weekAgo);
        case StatisticsFilterType.month:
          return d.month == (month ?? now.month) &&
              d.year == (year ?? now.year);
        case StatisticsFilterType.year:
          return d.year == (year ?? now.year);
        case StatisticsFilterType.lifetime:
          return true;
      }
    }).toList();
  }

  String _formatMonthKey(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]}, ${date.year}';
  }

  String _getMostFrequentKey(Map<String, double> map) {
    if (map.isEmpty) return 'N/A';
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _calculateAverageWatchedPerMonth(Map<String, int> monthly) {
    if (monthly.isEmpty) return 0.0;
    final total = monthly.values.reduce((a, b) => a + b);
    return total / monthly.length;
  }

  // ================= CUSTOM LISTS =================

  List<CustomList> getCustomLists() => List.unmodifiable(_customLists);

  Future<void> createCustomList(String name) async {
    if (_uid == null) return;

    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    if (_customLists.any((l) => l.name.toLowerCase() == trimmed.toLowerCase()))
      return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final list = CustomList(id: id, name: trimmed, items: []);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('customLists')
        .doc(id)
        .set(list.toMap());

    _customLists.add(list);
  }

  Future<void> loadCustomLists() async {
    if (_uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('customLists')
        .get();

    _customLists.clear();

    for (final doc in snapshot.docs) {
      _customLists.add(CustomList.fromMap(doc.data()));
    }
  }

  Future<void> deleteCustomList(String id) async {
    if (_uid == null) return;

    _customLists.removeWhere((l) => l.id == id);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('customLists')
        .doc(id)
        .delete();
  }

  CustomList? getCustomListById(String id) {
    return _customLists.firstWhere(
      (l) => l.id == id,
      orElse: () => null as CustomList,
    );
  }

  Future<void> renameCustomList(String id, String newName) async {
    if (_uid == null) return;

    final list = getCustomListById(id);
    if (list != null && newName.trim().isNotEmpty) {
      list.name = newName.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid!)
          .collection('customLists')
          .doc(id)
          .update({'name': list.name});
    }
  }

  Future<void> addMediaToCustomList(String listId, Media media) async {
    if (_uid == null) return;

    final list = getCustomListById(listId);
    if (list == null) return;

    list.addMedia(media);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('customLists')
        .doc(listId)
        .update({'items': list.items.map((e) => e.toMap()).toList()});
  }

  Future<void> removeMediaFromCustomList(String listId, Media media) async {
    if (_uid == null) return;

    final list = getCustomListById(listId);
    if (list == null) return;

    list.removeMedia(media);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('customLists')
        .doc(listId)
        .update({'items': list.items.map((e) => e.toMap()).toList()});
  }

  Future<void> setMediaStatus(Media media, String status) async {
    if (_uid == null) return;

    media.watchStatus = status;

    if (status == 'watched') {
      media.watched = true;
    } else {
      media.watched = false;
    }

    _watchStatus.removeWhere((m) => m.id == media.id);
    _watchStatus.add(media);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchStatuses')
        .doc(media.id)
        .set(media.toMap());
  }

  Future<void> removeMediaStatus(String mediaId) async {
    if (_uid == null) return;

    _watchStatus.removeWhere((m) => m.id == mediaId);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchStatuses')
        .doc(mediaId)
        .delete();
  }

  Future<void> loadWatchStatus() async {
    if (_uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .collection('watchStatuses')
        .get();

    _watchStatus.clear();

    for (final doc in snapshot.docs) {
      _watchStatus.add(Media.fromMap(doc.data()));
    }
  }

  List<Media> getWatchStatuses() => List.unmodifiable(_watchStatus);

  List<Media> getWatchedItems() =>
      _watchStatus.where((m) => m.watchStatus == 'watched').toList();

  List<Media> getWatchingItems() =>
      _watchStatus.where((m) => m.watchStatus == 'watching').toList();

  List<Media> getWantToWatchItems() =>
      _watchStatus.where((m) => m.watchStatus == 'want_to_watch').toList();

  Map<String, double> getMovieGenreCounts(List<Media> history) {
    final Map<String, double> counts = {};

    for (final media in history) {
      if (media.type.toLowerCase() == 'movie' && media.genre.isNotEmpty) {
        counts[media.genre] = (counts[media.genre] ?? 0) + 1;
      }
    }

    return counts;
  }

  Map<String, double> getTvGenreCounts(List<Media> history) {
    final Map<String, double> counts = {};

    for (final media in history) {
      if (media.type.toLowerCase().contains('tv') && media.genre.isNotEmpty) {
        counts[media.genre] = (counts[media.genre] ?? 0) + 1;
      }
    }

    return counts;
  }
}
