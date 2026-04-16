import 'dart:ffi';

import 'package:cinema_log/screens/notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/controller.dart';
import '../services/tracker_manager.dart';
import '../screens/welcome_user.dart';
import '../screens/search.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/profile.dart';
import '../models/statistics.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedIndex = 3;
  String mediaSelection = 'Combined';
  String timeSelection = 'Year of Choice';

  final List<String> mediaOptions = ['Movies', 'TV Shows', 'Combined'];

  final List<String> timeOptions = [
    'Last Week',
    'Month of Choice',
    'Year of Choice',
    'Selected Month Range',
  ];
  final months = [
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
  Map<int, double> sortedMoviesPerMonth = {};
  Map<int, double> sortedGenresPerYear = {};
  Statistics currentStats = TrackerManager().calculateStatistics(
    filter: StatisticsFilterType.year,
  );
  late Map<String, double> genreCounts = currentStats.genreCounts;
  List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'TV Movie',
    'Thriller',
    'War',
    'Western',
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, double> moviesWatchedPerMonth = TrackerManager()
        .getMoviesWatchedByMonth(TrackerManager().getWatchHistory());
    sortedMoviesPerMonth = sortWatched(moviesWatchedPerMonth);
    sortedGenresPerYear = sortGenres(genreCounts);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GradientText(
          'Cinema Log',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Your Movie Stats',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: mediaSelection,
                  dropdownColor: const Color(0xFF101728),
                  style: const TextStyle(color: Colors.white),
                  items: mediaOptions.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      mediaSelection = value!;
                    });
                  },
                ),

                DropdownButton<String>(
                  value: timeSelection,
                  dropdownColor: const Color(0xFF101728),
                  style: const TextStyle(color: Colors.white),
                  items: timeOptions.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      timeSelection = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSummaryText(),

            const SizedBox(height: 20),

            _createGraph(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Search()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomListsScreen()),
            );
          } else if (index == 3) {
            Profile.currentUser = WelcomeUser.currentUser;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Lists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  _createGraph() {
    if (timeSelection == 'Last Week') {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ), // Hides right Y values
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: monthTitles,
                ),
              ),
            ),
            barGroups: sortedMoviesPerMonth.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(toY: entry.value, color: Colors.blue),
                ],
              );
            }).toList(),
          ),
        ),
      );
    } else if (timeSelection == 'Month of Choice') {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ), // Hides right Y values
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: genreTitles,
                ),
              ),
            ),
            barGroups: sortedGenresPerYear.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(toY: entry.value, color: Colors.blue),
                ],
              );
            }).toList(),
          ),
        ),
      );
    } else if (timeSelection == 'Year of Choice') {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ), // Hides right Y values
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: genreTitles,
                ),
              ),
            ),
            barGroups: sortedGenresPerYear.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(toY: entry.value, color: Colors.blue),
                ],
              );
            }).toList(),
          ),
        ),
      );
    } else if (timeSelection == 'Selected Month Range') {
      // Implement the graph for selected month range
      return Container(); // Placeholder
    } else {
      return Container(); // Placeholder for any other cases
    }
  }

  Widget _buildSummaryText() {
    final tracker = TrackerManager();

    if (timeSelection == 'Last Week') {
      final stats = tracker.calculateStatistics(
        filter: StatisticsFilterType.week,
      );

      return Column(
        children: [
          Text(
            '${stats.totalMoviesWatched} movies watched last week',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '${stats.totalTvShowsWatched} TV shows watched last week',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    if (timeSelection == 'Year of Choice') {
      final stats = tracker.calculateStatistics(
        filter: StatisticsFilterType.year,
      );

      return Column(
        children: [
          Text(
            '${stats.totalMoviesWatched} movies watched this year',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '${stats.totalTvShowsWatched} TV shows watched this year',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Map<int, double> sortGenres(Map<String, double> genres) {
    Map<int, double> genreInt = {};
    for (var entry in genres.entries) {
      int genreID = parseGenre(entry.key);
      genreInt[genreID] = entry.value;
    }
    return genreInt;
  }

  int parseGenre(String key) {
    int genreNum = genres.indexOf(key);
    return genreNum;
  }

  Widget genreTitles(double value, TitleMeta meta) {
    const titleStyle = TextStyle(fontSize: 10);
    String genre = switch (value) {
      0 => genres[0],
      1 => genres[1],
      2 => genres[2],
      3 => genres[3],
      4 => genres[4],
      5 => genres[5],
      6 => genres[6],
      7 => genres[7],
      8 => genres[8],
      9 => genres[9],
      10 => genres[10],
      11 => genres[11],
      12 => genres[12],
      13 => genres[13],
      14 => genres[14],
      15 => genres[15],
      16 => genres[16],
      17 => genres[17],
      18 => genres[18],
      19 => genres[19],
      _ => '',
    };
    return SideTitleWidget(
      child: Text(genre, style: titleStyle),
      meta: meta,
    );
  }

  Map<int, double> sortWatched(Map<String, double> watchedmovies) {
    Map<int, double> watchedMoviesInt = {};
    for (var entry in watchedmovies.entries) {
      int monthNum = parseMonth(entry.key);
      watchedMoviesInt[monthNum] =
          (watchedMoviesInt[monthNum] ?? 0) + entry.value;
    }
    Map<int, double> finalWatchedMovies = {};
    for (var i = 1; i < 13; i++) {
      if (watchedMoviesInt.containsKey(i)) {
        finalWatchedMovies[i] = watchedMoviesInt[i]!;
      } else {
        finalWatchedMovies[i] = 0;
      }
    }
    return finalWatchedMovies;
  }

  int parseMonth(String key) {
    List<String> splitKey = key.split(',');
    String month = splitKey[0];
    int monthNum = months.indexOf(month);
    return monthNum + 1;
  }

  Widget monthTitles(double value, TitleMeta meta) {
    const titleStyle = TextStyle(fontSize: 10);
    String Month = switch (value) {
      1 => months[0],
      2 => months[1],
      3 => months[2],
      4 => months[3],
      5 => months[4],
      6 => months[5],
      7 => months[6],
      8 => months[7],
      9 => months[8],
      10 => months[9],
      11 => months[10],
      12 => months[11],
      _ => '',
    };
    return SideTitleWidget(
      child: Text(Month, style: titleStyle),
      meta: meta,
    );
  }
}
