import 'package:cinema_log/screens/search.dart';
import 'package:flutter/material.dart';

import 'package:cinema_log/models/custom_list.dart';
import 'package:cinema_log/services/controller.dart';
import 'package:cinema_log/screens/movie_details_screen.dart';
import 'package:cinema_log/widgets/media_tile.dart';

class CustomListDetailScreen extends StatefulWidget {
  final CustomList customList;

  const CustomListDetailScreen({super.key, required this.customList});

  @override
  State<CustomListDetailScreen> createState() => _CustomListDetailScreenState();
}

class _CustomListDetailScreenState extends State<CustomListDetailScreen> {
  final Controller _controller = Controller();

  @override
  Widget build(BuildContext context) {
    final CustomList? updatedList = _controller.getCustomListById(
      widget.customList.id,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          widget.customList.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: updatedList == null
          ? const Center(child: Text('This list no longer exists.'))
          : updatedList.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No media in this list yet.'),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white70),
                    onPressed: () {
                      Navigator.push(
                        //take user to search screen to add to list
                        context,
                        MaterialPageRoute(builder: (_) => Search()),
                      );
                    },
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: updatedList.items.length,
              itemBuilder: (context, index) {
                final media = updatedList.items[index];
                return MediaTile(
                  media: media,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsScreen(
                        mediaId: media.id.toString(),
                        mediaType: media.type,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white70),
                    onPressed: () async {
                      await _controller.removeMediaFromCustomList(
                        updatedList.id,
                        media,
                      );
                      await _controller.loadCustomLists();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Removed "${media.title}" from "${updatedList.name}".',
                          ),
                        ),
                      );

                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
