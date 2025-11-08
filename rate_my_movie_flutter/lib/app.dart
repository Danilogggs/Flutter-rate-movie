import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/my_movies_screen.dart';
import 'screens/edit_profile_screen.dart'; // <-- importe a tela de edição

class RateMyMovieApp extends StatelessWidget {
  const RateMyMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rate My Movie',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/search': (_) => const SearchScreen(),
        '/my-movies': (_) => const MyMoviesScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final id = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movieId: id),
          );
        }
        return null;
      },
    );
  }
}
