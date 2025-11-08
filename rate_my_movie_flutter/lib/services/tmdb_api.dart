import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDbApi {
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static const String _base = 'https://api.themoviedb.org/3';
  static const String imageBase = 'https://image.tmdb.org/t/p/w500';

  static Future<List<Map<String, dynamic>>> search(String query) async {
    final q = Uri.parse('$_base/search/movie?api_key=$_apiKey&language=pt-BR&query=${Uri.encodeComponent(query)}');
    final r = await http.get(q);
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body);
      final List results = data['results'] ?? [];
      return results.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro TMDb: ${r.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> details(int id) async {
    final q = Uri.parse('$_base/movie/$id?api_key=$_apiKey&language=pt-BR');
    final r = await http.get(q);
    if (r.statusCode == 200) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erro TMDb: ${r.statusCode}');
    }
  }
}
