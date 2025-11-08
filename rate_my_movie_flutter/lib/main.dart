import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as fo; // gerado pelo flutterfire configure, ficará ausente até você rodar o CLI
import 'providers/auth_provider.dart';
import 'providers/movies_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final useFirebase = (dotenv.env['USE_FIREBASE'] ?? 'false').toLowerCase() == 'true';
  if (useFirebase) {
    try {
      await Firebase.initializeApp(options: fo.DefaultFirebaseOptions.currentPlatform);
    } catch (_) {
      // Se não configurado ainda, o app continua para permitir você abrir e ajustar .env/rodar flutterfire
    }
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => MoviesProvider()),
    ],
    child: const RateMyMovieApp(),
  ));
}
