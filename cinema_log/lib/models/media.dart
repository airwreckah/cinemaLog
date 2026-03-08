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
}