import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/watched_entry.dart';
import '../services/tmdb_api.dart';
import '../services/storage_service.dart';

class MoviesProvider extends ChangeNotifier {
  List<Movie> results = [];
  List<WatchedEntry> watched = [];
  bool loading = false;
  String error = '';

  Future<void> search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      results = [];
      error = '';
      notifyListeners();
      return;
    }

    loading = true;
    error = '';
    notifyListeners();

    try {
      final raw = await TMDbApi.search(query);
      results = raw.map((m) => Movie.fromJson(m)).toList();
    } catch (e) {
      error = e.toString();
      results = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWatched(String userId) async {
    watched = await StorageService.getWatched(userId);
    notifyListeners();
  }

  Future<void> addWatched(String userId, WatchedEntry entry) async {
    await StorageService.addWatched(userId, entry);
    await loadWatched(userId); // refresh
  }

  // >>> NOVO: remover favorito
  Future<void> removeWatched(String userId, int movieId) async {
    await StorageService.deleteWatched(userId, movieId);
    await loadWatched(userId); // refresh
  }

  // >>> NOVO: utilitário – pega favorito por ID (ou null)
  WatchedEntry? getWatchedById(int movieId) {
    try {
      return watched.firstWhere((w) => w.movieId == movieId);
    } catch (_) {
      return null;
    }
  }

  // >>> NOVO: booleano rápido
  bool isWatched(int movieId) => watched.any((w) => w.movieId == movieId);
}
