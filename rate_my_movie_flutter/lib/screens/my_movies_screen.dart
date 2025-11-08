import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movies_provider.dart';
import '../providers/auth_provider.dart';
import '../services/tmdb_api.dart';

class MyMoviesScreen extends StatefulWidget {
  const MyMoviesScreen({super.key});

  @override
  State<MyMoviesScreen> createState() => _MyMoviesScreenState();
}

class _MyMoviesScreenState extends State<MyMoviesScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Carrega a lista uma única vez após montar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<MoviesProvider>().loadWatched(user.uid);
        setState(() => _loaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final watched = context.watch<MoviesProvider>().watched;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus filmes')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: watched.length,
              itemBuilder: (_, i) {
                final w = watched[i]; // WatchedEntry
                return ListTile(
                  leading: (w.posterPath.isNotEmpty)
                      ? Image.network(
                          TMDbApi.imageBase + w.posterPath,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          semanticLabel: 'Pôster de ${w.title}',
                        )
                      : const Icon(Icons.movie),
                  title: Text(w.title),
                  subtitle: Text('Minha nota: ${w.rating.toStringAsFixed(1)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/details', arguments: w.movieId);
                  },
                );
              },
            ),
    );
  }
}
