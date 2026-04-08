import 'package:flutter/material.dart';

import '../models/custom_list.dart';
import '../models/media.dart';
import '../services/controller.dart';
import 'movie.dart';
import 'movie_details_screen.dart';

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
      appBar: AppBar(title: Text(widget.customList.name)),
      body: updatedList == null
          ? const Center(child: Text('This list no longer exists.'))
          : updatedList.items.isEmpty
          ? const Center(child: Text('No movies in this list yet.'))
          : ListView.builder(
              itemCount: updatedList.items.length,
              itemBuilder: (context, index) {
                final media = updatedList.items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading:
                        media.posterPath != null && media.posterPath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '$Controller.mainImgUrl${media.posterPath}',
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.movie);
                              },
                            ),
                          )
                        : const Icon(Icons.movie),
                    title: Text(media.title),
                    subtitle: Text('${media.type} • ${media.year}'),

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MovieDetailsScreen(movieId: media.id.toString()),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _controller.removeMediaFromCustomList(
                          updatedList.id,
                          media,
                        );
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
                  ),
                );
              },
            ),
    );
  }
}
