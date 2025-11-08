import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tmdb_api.dart';
import '../providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../models/watched_entry.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? movie;
  double rating = 0.0;
  bool isFav = false;
  bool _loading = true;

  Future<void> _init() async {
    final data = await TMDbApi.details(widget.movieId);

    final mp = context.read<MoviesProvider>();
    final user = context.read<AuthProvider>().user;

    WatchedEntry? existing;
    if (user != null) {
      if (mp.watched.isEmpty) {
        await mp.loadWatched(user.uid);
      }
      existing = mp.getWatchedById(widget.movieId);
    }

    setState(() {
      movie = data;
      if (existing != null) {
        isFav = true;
        rating = existing.rating;
      }
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || movie == null) return;
    final title = (movie!['title'] ?? '').toString();
    final poster = (movie!['poster_path'] ?? '').toString();

    final entry = WatchedEntry(
      movieId: widget.movieId,
      title: title,
      posterPath: poster,
      rating: rating,
      createdAt: DateTime.now(),
    );

    await context.read<MoviesProvider>().addWatched(user.uid, entry);
    setState(() => isFav = true);

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Favoritos'),
          content: const Text('Filme salvo/atualizado com sucesso!'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _remove() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    await context.read<MoviesProvider>().removeWatched(user.uid, widget.movieId);
    setState(() => isFav = false);

    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Favoritos'),
          content: const Text('Filme removido dos favoritos.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || movie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = (movie!['title'] ?? 'Detalhes').toString();
    final poster = (movie!['poster_path'] ?? '').toString();
    final overview = (movie!['overview'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (poster.isNotEmpty)
            Image.network(TMDbApi.imageBase + poster, semanticLabel: 'Pôster do filme $title'),
          const SizedBox(height: 12),
          Text(overview),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Sua nota:'),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: rating,
                items: List.generate(6, (i) => i.toDouble())
                    .map((v) => DropdownMenuItem(value: v, child: Text(v.toStringAsFixed(1))))
                    .toList(),
                onChanged: (v) => setState(() => rating = v ?? 0.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _save,
            child: Text(isFav ? 'Atualizar nota' : 'Salvar na minha lista'),
          ),
          const SizedBox(height: 8),
          if (isFav)
            OutlinedButton.icon(
              onPressed: _remove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover dos favoritos'),
            ),
        ],
      ),
    );
  }
}
