import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final String uid;
  final String email;
  AuthResult(this.uid, this.email);
}

class AuthService {
  static bool get useFirebase =>
      (dotenv.env['USE_FIREBASE'] ?? 'false').toLowerCase() == 'true';

  // ==== Firebase ====
  static final _fbAuth = fb.FirebaseAuth.instance;
  static final _fs = FirebaseFirestore.instance;

  // ----------------- Autenticação básica -----------------
  static Future<AuthResult> signIn(String email, String password) async {
    if (useFirebase) {
      final creds = await _fbAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final u = creds.user!;
      return AuthResult(u.uid, u.email!);
    } else {
      // local fake multi-user auth
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final user = map[email];
      if (user == null) throw Exception('E-mail não encontrado');
      if (user['password'] != password) throw Exception('Senha incorreta');
      // no modo local usamos o próprio e-mail como uid
      return AuthResult(email, email);
    }
  }

  static Future<AuthResult> register(
    String name,
    String email,
    String password, {
    String? photoPath,
  }) async {
    if (useFirebase) {
      final creds = await _fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final u = creds.user!;
      await u.updateDisplayName(name);

      // opcional: manter dados base em "users/{uid}"
      await _fs.collection('users').doc(u.uid).set({
        'name': name,
        'email': email,
        if (photoPath != null) 'photoPath': photoPath, // string local (não é upload)
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return AuthResult(u.uid, u.email!);
    } else {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map.containsKey(email)) {
        throw Exception('E-mail já cadastrado');
      }
      map[email] = {
        'name': name,
        'email': email,
        'password': password,
        'photoPath': photoPath,
      };
      await sp.setString('users', jsonEncode(map));
      return AuthResult(email, email);
    }
  }

  static Future<void> signOut() async {
    if (useFirebase) {
      await _fbAuth.signOut();
    } else {
      // nada
    }
  }

  static Future<void> sendPasswordReset(String email) async {
    if (useFirebase) {
      await _fbAuth.sendPasswordResetEmail(email: email);
    } else {
      throw Exception('Esqueci minha senha requer Firebase (USE_FIREBASE=true)');
    }
  }

  static String? currentUid() {
    if (useFirebase) {
      final u = _fbAuth.currentUser;
      return u?.uid;
    } else {
      return null; // Provider guarda o uid local
    }
  }

  // ----------------- Atualizações de perfil -----------------
  static Future<void> updateProfile(
    String uid,
    String name, {
    String? photoPath,
  }) async {
    if (useFirebase) {
      final u = _fbAuth.currentUser;
      if (u != null) {
        await u.updateDisplayName(name);
      }
      await _fs.collection('users').doc(uid).set({
        'name': name,
        if (photoPath != null) 'photoPath': photoPath,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // uid == email no modo local
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final user = map[uid];
      if (user == null) throw Exception('Usuário local não encontrado');
      user['name'] = name;
      if (photoPath != null) user['photoPath'] = photoPath;
      map[uid] = user;
      await sp.setString('users', jsonEncode(map));
    }
  }

  static Future<void> updateEmail(String uid, String newEmail) async {
    if (useFirebase) {
      final u = _fbAuth.currentUser;
      if (u == null) throw Exception('Usuário não autenticado');
      await u.updateEmail(newEmail); // pode exigir reautenticação
      await _fs.collection('users').doc(uid).set({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // uid == email antigo no modo local
      final oldEmail = uid;
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;

      final user = map[oldEmail];
      if (user == null) throw Exception('Usuário local não encontrado');

      // reindexa usuário pela nova chave (email)
      user['email'] = newEmail;
      map.remove(oldEmail);
      map[newEmail] = user;
      await sp.setString('users', jsonEncode(map));

      // migra a lista "watched_<email>"
      final oldWatchedKey = 'watched_$oldEmail';
      final newWatchedKey = 'watched_$newEmail';
      final watchedRaw = sp.getString(oldWatchedKey);
      if (watchedRaw != null) {
        await sp.setString(newWatchedKey, watchedRaw);
        await sp.remove(oldWatchedKey);
      }
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    if (useFirebase) {
      final u = _fbAuth.currentUser;
      if (u == null) throw Exception('Usuário não autenticado');
      await u.updatePassword(newPassword); // pode exigir reautenticação
    } else {
      // No modo local, quem faz o update é o AuthProvider (pois precisa do e-mail atual)
      // Mantemos aqui vazio para compatibilidade.
    }
  }

  static Future<void> deleteAccount(String uid, String emailForLocalMode) async {
    if (useFirebase) {
      // apaga subcoleção watched
      final entries = await _fs
          .collection('watched')
          .doc(uid)
          .collection('entries')
          .get();
      for (final d in entries.docs) {
        await d.reference.delete();
      }
      // apaga doc do usuário
      await _fs.collection('users').doc(uid).delete();
      // apaga usuário do Auth
      await _fbAuth.currentUser?.delete();
    } else {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map.remove(emailForLocalMode);
      await sp.setString('users', jsonEncode(map));
      await sp.remove('watched_$emailForLocalMode');
    }
  }
}
