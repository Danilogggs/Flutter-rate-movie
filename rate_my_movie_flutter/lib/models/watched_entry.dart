class WatchedEntry {
  final int movieId;
  final String title;
  final String posterPath;
  final double rating; // 0..5
  final DateTime createdAt;

  WatchedEntry({
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'movieId': movieId,
        'title': title,
        'posterPath': posterPath,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WatchedEntry.fromMap(Map<String, dynamic> m) => WatchedEntry(
        movieId: m['movieId'],
        title: m['title'],
        posterPath: m['posterPath'] ?? '',
        rating: (m['rating'] ?? 0).toDouble(),
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );
}
