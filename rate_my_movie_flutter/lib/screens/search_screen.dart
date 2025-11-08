import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MoviesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar filmes'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: 'Meus filmes',
            onPressed: () => Navigator.pushNamed(context, '/my-movies'),
            icon: const Icon(Icons.movie_filter),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _query,
              decoration: const InputDecoration(
                labelText: 'Digite o nome do filme',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  context.read<MoviesProvider>().search(v.trim());
                }
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: mp.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: mp.results.length,
                      itemBuilder: (_, i) {
                        final m = mp.results[i];
                        return MovieCard(
                          title: m.title,
                          posterPath: m.posterPath,
                          altText: 'Pôster do filme ${m.title}',
                          onTap: () => Navigator.pushNamed(context, '/details', arguments: m.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
