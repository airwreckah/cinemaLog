import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../screens/welcome_user.dart';
import '../screens/custom_lists_screen.dart';
import '../screens/search.dart';
import '../screens/profile.dart';
import '../services/controller.dart';
import '../models/media.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class notesScreen extends StatefulWidget {
  
  final Media media;

  const notesScreen({super.key, required this.media});

  @override
  State<notesScreen> createState() => _notesScreenState();
}

class _notesScreenState extends State<notesScreen> {
  int selectedIndex = 0;
  bool selected = false;
  String noteText = '';
  Map<String, dynamic>? _movieData;
  int currentRating = 0;
  DateTime watchDate = DateTime.now();
  Map<String, dynamic>? movieData;
  final Controller controller = Controller();
  

  Future<void> selectWatchDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        watchDate = selectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _movieData = widget.media.toMap();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.media.title.isNotEmpty
        ? widget.media.title
        : (_movieData?['title'] ?? _movieData?['name'] ?? 'Untitled');

    final overview = _movieData?['overview'] ?? 'No summary available.';
    final poster_path = _movieData?['poster_path'];

    final String releaseDate =
        _movieData?['release_date'] ??
        _movieData?['first_air_date'] ??
        'Unknown';

    final String releaseYear =
        releaseDate != 'Unknown' && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : 'Unknown';

    final String rating = _movieData?['vote_average']?.toString() ?? 'N/A';

    final String runtime = _movieData?['runtime'] != null
        ? '${_movieData!['runtime']} min'
        : _movieData?['number_of_seasons'] != null
        ? '${_movieData!['number_of_seasons']} season${_movieData!['number_of_seasons'] == 1 ? '' : 's'}'
        : 'Unknown';

    final List genresList = _movieData!['genres'] ?? [];
    final String genre = genresList.isNotEmpty
        ? genresList.first['name'] ?? ''
        : '';
    String currentNotes = widget.media.notes ?? '';
    currentRating = widget.media.rating ?? 0;
    final TextEditingController notesController = TextEditingController(text: currentNotes);
    

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
          ),
          colors: const [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            padding: const EdgeInsets.only(right: 20),
            iconSize: 35,
            color: Colors.white,
            onPressed: () async {
              await controller.markAsWatchedWithNotes(
                widget.media,
                notesController.text,
                currentRating,
                watchDate,
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // POSTER
            if (poster_path != null)
              Center(
                child: Image.network(
                  '${Controller.mainImgURL}/$poster_path',
                  height: 200,
                ),
              ),
            if (poster_path == null)
              Container(
                height: 200,
                color: Colors.white24,
                child: const Center(
                  child: Text(
                    'No Image',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ⭐ RATING STARS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      (index < currentRating && selected)
                          ? Icons.star
                          : Icons.star_border,
                    ),
                    iconSize: 25,
                    color: Colors.amber,
                    onPressed: () {
                      setState(() {
                        selected = true;
                        currentRating = index + 1;
                      });
                    },
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // NOTES HEADER + DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        selectWatchDate(context);
                      },
                    ),
                    Text(
                      "${watchDate.month}/${watchDate.day}/${watchDate.year}",
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // NOTES INPUT
            if(currentNotes.isNotEmpty)
              SizedBox(
              height: 300,
              child: TextField(
                controller: notesController,
                maxLines: 30,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (input) {
                  noteText = notesController.text;
                },
              ),
            ),
            if(currentNotes.isEmpty)
              SizedBox(
                height: 300,
                child: TextField(
                  controller: notesController,
                  maxLines: 30,
                  decoration: InputDecoration(
                    hintText: 'Write your notes here...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (input) {
                    noteText = notesController.text;
                  },
                ),
              ),
          ],
        ),
      ),

      // NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Search()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomListsScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          }

          setState(() {
            selectedIndex = index;
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
}
