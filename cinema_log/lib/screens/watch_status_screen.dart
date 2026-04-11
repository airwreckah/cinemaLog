import 'package:flutter/material.dart';
import '../services/controller.dart';
import '../models/media.dart';
import 'movie_details_screen.dart';

class WatchStatusScreen extends StatefulWidget {
  const WatchStatusScreen({super.key});

  @override
  State<WatchStatusScreen> createState() => _WatchStatusScreenState();
}

class _WatchStatusScreenState extends State<WatchStatusScreen> {
  final Controller _controller = Controller();

  @override
  void initState() {
    super.initState();
    _controller.loadWatchStatus().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final watched = _controller.getWatchedItems();
    final watching = _controller.getWatchingItems();
    final wantToWatch = _controller.getWantToWatchItems();

    return Scaffold(
      appBar: AppBar(title: const Text("Watch Status")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection("Watched", watched),
          _buildSection("Watching", watching),
          _buildSection("Want to Watch", wantToWatch),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Media> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty) const Text("No items"),
        ...items.map((media) {
          return ListTile(
            title: Text(media.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailsScreen(movieId: media.id),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
