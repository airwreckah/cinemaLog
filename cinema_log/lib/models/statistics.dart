class Statistics {
  final int totalMoviesWatched;
  final int totalTvShowsWatched;
  final int totalItemsWatched;
  final Map<String, int> moviesWatchedPerMonth;
  final Map<String, int> genreCounts;
  final String mostViewedGenre;
  final double averageWatchedPerMonth;

  Statistics({
    required this.totalMoviesWatched,
    required this.totalTvShowsWatched,
    required this.totalItemsWatched,
    required this.moviesWatchedPerMonth,
    required this.genreCounts,
    required this.mostViewedGenre,
    required this.averageWatchedPerMonth,
  });
}
