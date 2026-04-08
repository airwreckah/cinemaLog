class Media {
  final String id;
  final String title;
  final String type;
  final int year;
  final String genre;
  final String? posterPath;
  bool watched;

  DateTime? watchDate;

  Media({
    required this.id,
    required this.title,
    required this.type,
    required this.year,
    required this.genre,
    this.posterPath,
    this.watched = false,
    this.watchDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'year': year,
      'genre': genre,
      'posterPath': posterPath,
      'watched': watched,
      'watchDate': watchDate?.toIso8601String(),
    };
  }

  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      year: map['year'],
      genre: map['genre'],
      posterPath: map['posterPath'],
      watched: map['watched'] ?? false,
      watchDate: map['watchDate'] != null
          ? DateTime.parse(map['watchDate'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Media && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
