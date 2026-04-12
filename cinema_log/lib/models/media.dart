class Media {
  final String id;
  final String title;
  final String type;
  final int year;
  final String genre;
  final String? posterPath;
  bool watched;
  int? rating;
  String? notes;
  String? watchStatus;

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
    this.rating,
    this.notes,
    this.watchStatus,
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
      'rating': rating,
      'notes': notes,
      'watchStatus': watchStatus,
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
      rating: map['rating'],
      notes: map['notes'],
      watchStatus: map['watchStatus'],
    );
  }

  void setWatchDate(DateTime watchDate){
    this.watchDate = watchDate;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Media && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
