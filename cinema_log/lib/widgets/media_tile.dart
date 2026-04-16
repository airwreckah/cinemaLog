import 'package:flutter/material.dart';
import '../models/media.dart';
import '../services/controller.dart';

class MediaTile extends StatelessWidget {
  final Media media;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showTypeAndYear;

  const MediaTile({
    super.key,
    required this.media,
    this.onTap,
    this.trailing,
    this.showTypeAndYear = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0A1228),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: media.poster_path != null && media.poster_path!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${Controller.mainImgURL}/${media.poster_path}',
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 50,
                      height: 75,
                      child: Icon(Icons.movie, color: Colors.white70),
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
          showTypeAndYear
              ? '${media.type} • ${media.year}'
              : media.year.toString(),
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
