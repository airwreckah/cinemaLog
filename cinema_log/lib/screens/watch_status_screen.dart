import 'package:cinema_log/widgets/media_tile.dart';
import 'package:flutter/material.dart';

import '../screens/notes_screen.dart';
import '../models/media.dart';
import '../services/controller.dart';
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
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final watched = _controller.getWatchedItems();
    final watching = _controller.getWatchingItems();
    final wantToWatch = _controller.getWantToWatchItems();

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Watch Status',
        style: TextStyle(
          color: Colors.white,
          )),
          iconTheme: const IconThemeData(
            color: Colors.white
          )),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExpandableSection('Watched', watched),
            _buildExpandableSection('Watching', watching),
            _buildExpandableSection('Want to Watch', wantToWatch),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<Media> items) {
    return Card(
      color: const Color(0xFF101728),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            '$title (${items.length})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: items.isEmpty
              ? [
                  const ListTile(
                    title: Text(
                      'No items',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ] : items.map((media) {
                  return ListTile(
                    title: Text(media.title,
                      style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                    subtitle: Column( mainAxisAlignment: MainAxisAlignment.start, 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Divider(color: Colors.white54),
                      ?media.rating != null
                        ? Text(
                            '${media.rating} ⭐',
                            style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600),
                          )
                        : null,
                      ?media.notes != null && media.notes!.isNotEmpty
                        ? Text(
                            media.notes!,
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                      ],
                    ),
                    trailing: TextButton(
                      child: const Text('Details',
                      style: TextStyle(color: Colors.white)),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => notesScreen(
                              media: media,
                              
                            ),
                          ),
                        );
                      }),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailsScreen(
                            mediaId: media.id.toString(),
                            mediaType: media.type,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
        ),
      ),
    );
  }
}
