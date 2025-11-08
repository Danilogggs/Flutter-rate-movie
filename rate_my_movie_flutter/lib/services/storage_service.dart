import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/watched_entry.dart';

class StorageService {
  static bool get useFirebase =>
      (dotenv.env['USE_FIREBASE'] ?? 'false').toLowerCase() == 'true';

  static final _fs = FirebaseFirestore.instance;

  static Future<List<WatchedEntry>> getWatched(String userId) async {
    if (useFirebase) {
      final snap = await _fs
          .collection('watched')
          .doc(userId)
          .collection('entries')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => WatchedEntry.fromMap(d.data())).toList();
    } else {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('watched_$userId') ?? '[]';
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((m) => WatchedEntry.fromMap(m)).toList();
    }
  }

  static Future<void> addWatched(String userId, WatchedEntry e) async {
    if (useFirebase) {
      final ref = _fs
          .collection('watched')
          .doc(userId)
          .collection('entries')
          .doc('${e.movieId}');
      await ref.set(e.toMap());
    } else {
      final sp = await SharedPreferences.getInstance();
      final list = await getWatched(userId);
      final idx = list.indexWhere((w) => w.movieId == e.movieId);
      if (idx >= 0) {
        list[idx] = e;
      } else {
        list.add(e);
      }
      final out = list.map((x) => x.toMap()).toList();
      await sp.setString('watched_$userId', jsonEncode(out));
    }
  }

  // >>> NOVO: remover um filme dos favoritos
  static Future<void> deleteWatched(String userId, int movieId) async {
    if (useFirebase) {
      final ref = _fs
          .collection('watched')
          .doc(userId)
          .collection('entries')
          .doc('$movieId');
      await ref.delete();
    } else {
      final sp = await SharedPreferences.getInstance();
      final list = await getWatched(userId);
      list.removeWhere((w) => w.movieId == movieId);
      final out = list.map((x) => x.toMap()).toList();
      await sp.setString('watched_$userId', jsonEncode(out));
    }
  }
}
