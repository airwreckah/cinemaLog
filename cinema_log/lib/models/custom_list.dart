import 'media.dart';

class CustomList {
  final String id;
  String name;
  final List<Media> items;

  CustomList({required this.id, required this.name, List<Media>? items})
    : items = items ?? [];

  void addMedia(Media media) {
    if (!items.contains(media)) {
      items.add(media);
    }
  }

  void removeMedia(Media media) {
    items.remove(media);
  }
}
