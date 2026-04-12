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
  Map<String, double> moviesWatchedPerMonth = TrackerManager().getMoviesWatchedByMonth(TrackerManager().getWatchHistory());
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
  List<int> monthsAsNum = [];


  @override
  Widget build(BuildContext context) {
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
          SizedBox(
            height: 300,
            width: 300,
            child: BarChart(
              BarChartData(
                barGroups: moviesWatchedPerMonth.entries.map((entry) {
                  int index = parseMonth(entry.key);
                  return BarChartGroupData(
                    x: index,
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

    int parseMonth(String key){
    List<String> splitKey = key.split(',');
    String month = splitKey[0];
    int monthNum = months.indexOf(month);
    return monthNum + 1;
  }
}