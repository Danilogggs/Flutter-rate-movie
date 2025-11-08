import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String posterPath;
  final String altText;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.title,
    required this.posterPath,
    required this.altText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = posterPath.isNotEmpty
        ? Image.network(
            TMDbApi.imageBase + posterPath,
            fit: BoxFit.cover,
            semanticLabel: altText,
          )
        : Container(color: Colors.grey.shade300);

    return Semantics(
      label: 'Filme: $title',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(width: 80, height: 120, child: img),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
