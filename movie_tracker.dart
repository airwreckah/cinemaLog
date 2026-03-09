import 'package:movie_tracker/movie_tracker.dart' as movie_tracker;

class Controller {
  TrackerManager trackerManager = TrackerManager();

  void addMovie(String name) {
    trackerManager.addMovie(name);
  }
}

void main(List<String> arguments) {
  Controller controller = Controller();

  print(controller.addMovie("The Matrix"));
  print(controller.addMovie("Fight Club"));

  print(controller.searchMovie("The Matrix"));

  print(controller.listMovies);
}
