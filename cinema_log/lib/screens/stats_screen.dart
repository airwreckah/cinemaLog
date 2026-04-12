import 'package:cinema_log/screens/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/controller.dart';
import '../services/tracker_manager.dart';
import '../screens/welcome_user.dart';
import '../screens/search.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/profile.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();

}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedIndex = 3;
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  Map<int, double> sortedMoviesPerMonth = {};

  @override
  Widget build(BuildContext context) {
    Map<String, double> moviesWatchedPerMonth = TrackerManager().getMoviesWatchedByMonth(TrackerManager().getWatchHistory());
    sortedMoviesPerMonth = sortMap(moviesWatchedPerMonth);
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
            SizedBox(height: 20),
            Text(
              'Your Movie Stats',
              style: TextStyle(
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text('Movies watched this year',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Hides right Y values
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: monthTitles
                    )
                  )
                ),
                barGroups: sortedMoviesPerMonth.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: Colors.blue,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          ),
          SizedBox(height: 20),
          Text('Most Watched Genres'),
          SizedBox(height: 20),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: BarChart(

            )
          )

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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }



    Map<int, double> sortMap(Map<String, double> watchedmovies){
      Map<int, double> watchedMoviesInt = {};
      for (var entry in watchedmovies.entries) {
        int monthNum = parseMonth(entry.key);
        watchedMoviesInt[monthNum] = (watchedMoviesInt[monthNum] ?? 0) + entry.value;
      }
      Map<int, double> finalWatchedMovies = {};
      for (var i = 1; i < 13; i++){
        if(watchedMoviesInt.containsKey(i)){
          finalWatchedMovies[i] = watchedMoviesInt[i]!;
        }
        else{
          finalWatchedMovies[i] = 0;
        }
      }
      return finalWatchedMovies;
    }

    int parseMonth(String key){
    List<String> splitKey = key.split(',');
    String month = splitKey[0];
    int monthNum = months.indexOf(month);
    return monthNum + 1;
  }

  Widget monthTitles(double value, TitleMeta meta){
      const titleStyle =  TextStyle(fontSize: 10);
      String Month = switch(value){
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
      return SideTitleWidget(child: Text(Month, style: titleStyle), meta: meta);
    }
}