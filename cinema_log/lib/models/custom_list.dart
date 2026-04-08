import 'media.dart';

class CustomList {
  final String id;
  String name;
  final List<Media> items;

  CustomList({required this.id, required this.name, List<Media>? items})
    : items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory CustomList.fromMap(Map<String, dynamic> map) {
    return CustomList(
      id: map['id'],
      name: map['name'],
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => Media.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  void addMedia(Media media) {
    if (!items.contains(media)) {
      items.add(media);
    }
  }

  void removeMedia(Media media) {
    items.remove(media);
  }
}
