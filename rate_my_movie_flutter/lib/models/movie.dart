class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        overview: j['overview'] ?? '',
        posterPath: j['poster_path'] ?? '',
        releaseDate: j['release_date'] ?? '',
      );
}
