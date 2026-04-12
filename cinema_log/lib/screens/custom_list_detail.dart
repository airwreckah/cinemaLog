import 'package:flutter/material.dart';

import '../models/custom_list.dart';
import '../services/controller.dart';
import 'movie_details_screen.dart';
import '../widgets/media_tile.dart';

class CustomListDetailScreen extends StatefulWidget {
  final CustomList customList;

  const CustomListDetailScreen({
    super.key,
    required this.customList,
  });

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
      appBar: AppBar(title: Text(widget.customList.name)),
      body: updatedList == null
          ? const Center(child: Text('This list no longer exists.'))
          : updatedList.items.isEmpty
              ? const Center(child: Text('No media in this list yet.'))
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