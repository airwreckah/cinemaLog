import 'package:flutter/material.dart';

import '../models/custom_list.dart';
import '../models/media.dart';
import '../services/controller.dart';
import 'movie.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.customList.name),
      ),
      body: updatedList == null
          ? const Center(
              child: Text(
                'This list no longer exists.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : updatedList.items.isEmpty
          ? const Center(
              child: Text(
                'No movies in this list yet.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: updatedList.items.length,
              itemBuilder: (context, index) {
                final media = updatedList.items[index];
                return Card(
                  color: const Color(0xFF0A1228),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),

                    leading:
                        media.posterPath != null && media.posterPath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${Controller.mainImgURL}/${media.posterPath}',
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 50,
                                  height: 75,
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.white70,
                                  ),
                                );
                              },
                            ),
                          )
                        : const SizedBox(
                            width: 50,
                            height: 75,
                            child: Icon(Icons.movie, color: Colors.white70),
                          ),
                    title: Text(
                      media.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      media.year.toString(),
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white70),
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Movie(
                          movie: {
                            'id': media.id,
                            'title': media.title,
                            'type': media.type,
                            'release_date': media.year.toString(),
                            'overview': 'No description available',
                            'poster_path': media.posterPath ?? '',
                            'vote_average': 0,
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
