import 'package:cinema_log/screens/custom_lists_screen.dart';
import 'package:cinema_log/screens/profile.dart';
import 'package:cinema_log/screens/search.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/services/tracker_manager.dart';
import 'package:cinema_log/models/statistics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final Controller _controller = Controller();

  int _selectedIndex = 3;

  String mediaSelection = 'Combined';
  String timeSelection = 'Overall';

  final List<String> mediaOptions = ['Combined', 'Movies', 'TV Shows'];
  final List<String> timeOptions = [
    'Overall',
    'Last Week',
    'Month',
    'Year',
    'Custom Range',
  ];

  Statistics _currentStats = Statistics(
    totalMoviesWatched: 0,
    totalTvShowsWatched: 0,
    totalItemsWatched: 0,
    moviesWatchedPerMonth: {},
    genreCounts: {},
    mostViewedGenre: 'N/A',
    averageWatchedPerMonth: 0,
  );

  int? selectedMonth;
  int? selectedYear;
  DateTimeRange? selectedDateRange;

  final List<String> months = const [
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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _controller.loadWatchHistory();

    final now = DateTime.now();

    setState(() {
      selectedMonth ??= now.month;
      selectedYear ??= now.year;
      _currentStats = _controller.calculateStatistics(
        filterType: _mapTimeSelectionToFilter(),
        mediaType: _mapMediaSelectionToType(),
        month: selectedMonth,
        year: selectedYear,
        customRange: timeSelection == 'Custom Range' ? selectedDateRange : null,
      );
    });
  }

  StatsMediaType _mapMediaSelectionToType() {
    switch (mediaSelection) {
      case 'Movies':
        return StatsMediaType.movies;
      case 'TV Shows':
        return StatsMediaType.tv;
      case 'Combined':
      default:
        return StatsMediaType.combined;
    }
  }

  StatisticsFilterType _mapTimeSelectionToFilter() {
    switch (timeSelection) {
      case 'Last Week':
        return StatisticsFilterType.week;
      case 'Month':
        return StatisticsFilterType.month;
      case 'Year':
        return StatisticsFilterType.year;
      case 'Custom Range':
        return StatisticsFilterType.lifetime;
      case 'Overall':
      default:
        return StatisticsFilterType.lifetime;
    }
  }

  Future<void> _onTimeSelectionChanged(String value) async {
    setState(() {
      timeSelection = value;
    });

    if (value == 'Custom Range') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDateRange: selectedDateRange,
      );

      if (picked != null) {
        selectedDateRange = picked;
      } else {
        setState(() {
          timeSelection = 'Overall';
        });
      }
    }

    await _loadStats();
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
        selectedYear ?? now.year,
        selectedMonth ?? now.month,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
      fieldHintText: 'MM/YYYY',
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked.month;
        selectedYear = picked.year;
      });
      await _loadStats();
    }
  }

  Future<void> _pickYear() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear ?? now.year),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Year',
      fieldHintText: 'YYYY',
    );

    if (picked != null) {
      setState(() {
        selectedYear = picked.year;
      });
      await _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartTitle = _buildChartTitle();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GradientText(
          'Cinema Log',
          style: const TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: const [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Your Statistics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Media Type',
                    value: mediaSelection,
                    items: mediaOptions,
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        mediaSelection = value;
                      });
                      await _loadStats();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Time Range',
                    value: timeSelection,
                    items: timeOptions,
                    onChanged: (value) async {
                      if (value == null) return;
                      await _onTimeSelectionChanged(value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (timeSelection == 'Month')
              _buildPickerButton(
                label: selectedMonth == null || selectedYear == null
                    ? 'Choose Month'
                    : '${months[selectedMonth! - 1]} ${selectedYear!}',
                onTap: _pickMonth,
              ),

            if (timeSelection == 'Year')
              _buildPickerButton(
                label: selectedYear == null
                    ? 'Choose Year'
                    : selectedYear.toString(),
                onTap: _pickYear,
              ),

            if (timeSelection == 'Custom Range' && selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${selectedDateRange!.start.month}/${selectedDateRange!.start.day}/${selectedDateRange!.start.year} - '
                  '${selectedDateRange!.end.month}/${selectedDateRange!.end.day}/${selectedDateRange!.end.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

            _buildSummaryCards(),
            const SizedBox(height: 24),

            Text(
              chartTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(height: 300, child: _buildChart()),

            const SizedBox(height: 20),

            Text(
              'Most Watched Genre: ${_currentStats.mostViewedGenre}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF101728),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF101728),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPickerButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF101728),
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Movies',
            value: _currentStats.totalMoviesWatched.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'TV Shows',
            value: _currentStats.totalTvShowsWatched.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total',
            value: _currentStats.totalItemsWatched.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101728),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (timeSelection == 'Year') {
      final monthData = _buildMonthlyChartData(
        _currentStats.moviesWatchedPerMonth,
      );

      if (monthData.isEmpty) {
        return const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _monthTitles,
              ),
            ),
          ),
          barGroups: monthData.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF615FFF),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }

    final genreData = _buildGenreChartData(_currentStats.genreCounts);

    if (genreData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return BarChart(
      BarChartData(
        backgroundColor: Colors.transparent,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                final genre = genreData[value.toInt()]?.key ?? '';
                return SideTitleWidget(
                  meta: meta,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      genre.length > 8 ? '${genre.substring(0, 8)}…' : genre,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: genreData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                width: 18,
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFFAD46FF),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Map<int, double> _buildMonthlyChartData(Map<String, int> monthlyMap) {
    final Map<int, double> result = {for (int i = 1; i <= 12; i++) i: 0};

    monthlyMap.forEach((key, value) {
      final monthNumber = _parseMonthFromKey(key);
      if (monthNumber != null) {
        result[monthNumber] = value.toDouble();
      }
    });

    return result;
  }

  Map<int, MapEntry<String, double>> _buildGenreChartData(
    Map<String, double> genreMap,
  ) {
    final sortedEntries = genreMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = sortedEntries.take(8).toList();

    return {for (int i = 0; i < topEntries.length; i++) i: topEntries[i]};
  }

  int? _parseMonthFromKey(String key) {
    final split = key.split(',');
    if (split.isEmpty) return null;

    final monthName = split.first.trim();
    final index = months.indexOf(monthName);
    if (index == -1) return null;

    return index + 1;
  }

  Widget _monthTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 1 || index > 12) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        months[index - 1],
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }

  String _buildChartTitle() {
    final mediaLabel = mediaSelection == 'Combined'
        ? 'Genres Watched'
        : mediaSelection == 'Movies'
        ? 'Movie Genres Watched'
        : 'TV Genres Watched';

    switch (timeSelection) {
      case 'Last Week':
        return '$mediaLabel Last Week';
      case 'Month':
        if (selectedMonth != null && selectedYear != null) {
          return '$mediaLabel in ${months[selectedMonth! - 1]} $selectedYear';
        }
        return '$mediaLabel This Month';
      case 'Year':
        return 'Items Watched Per Month';
      case 'Custom Range':
        return '$mediaLabel in Selected Range';
      case 'Overall':
      default:
        return '$mediaLabel Overall';
    }
  }
}
