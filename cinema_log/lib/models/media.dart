class Media {
    final String id;
    final String title;
    final String type;
    final int year;
    bool watched;

    Media({
        required this.id,
        required this.title,
        required this.type,
        required this.year,
        this.watched = false,
    });

    @override
    bool operator ==(Object other) {
      if (identical(this, other)) return true;
      return other is Media && other.id == id;
    }

    @override
    int get hashCode => id.hashCode;
}