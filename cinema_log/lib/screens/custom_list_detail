import 'package:flutter/material.dart';

import '../models/custom_list.dart';
import '../models/media.dart';
import '../services/controller.dart';

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
    final updatedList = _controller.getCustomListById(widget.customList.id);

    if (updatedList == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Custom List'),
        ),
        body: const Center(
          child: Text('This list no longer exists.'),
        ),
      );
    }

    final List<Media> items = updatedList.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedList.name),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text('No movies in this list yet.'),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final media = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.movie),
                    title: Text(media.title),
                    subtitle: Text('${media.type} • ${media.year}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _controller.removeMediaFromCustomList(
                          updatedList.id,
                          media,
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