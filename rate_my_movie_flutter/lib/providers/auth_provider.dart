import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _user;
  UserProfile? get user => _user;

  final _fs = FirebaseFirestore.instance;

  // ===================== Login =====================
  Future<void> signIn(String email, String password) async {
    final res = await AuthService.signIn(email, password);

    if (AuthService.useFirebase) {
      final doc = await _fs.collection('users').doc(res.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _user = UserProfile(
          uid: res.uid,
          name: (data['name'] ?? (email.split('@').first)).toString(),
          email: (data['email'] ?? res.email).toString(),
          photoPath: data['photoPath'],
        );
      } else {
        _user = UserProfile(
          uid: res.uid,
          name: email.split('@').first,
          email: res.email,
        );
      }
    } else {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final u = map[email];
      _user = UserProfile(
        uid: res.uid, // no local, uid == email
        name: u['name'],
        email: u['email'],
        photoPath: u['photoPath'],
      );
    }

    notifyListeners();
  }

  // ===================== Cadastro =====================
  Future<void> register(
    String name,
    String email,
    String password, {
    String? photoPath,
  }) async {
    final res = await AuthService.register(
      name,
      email,
      password,
      photoPath: photoPath,
    );

    if (AuthService.useFirebase) {
      await _fs.collection('users').doc(res.uid).set({
        'uid': res.uid,
        'name': name,
        'email': email,
        'photoPath': photoPath, // caminho local no device atual
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      _user = UserProfile(
        uid: res.uid,
        name: name,
        email: email,
        photoPath: photoPath,
      );
    } else {
      _user = UserProfile(
        uid: res.uid, // no local, uid == email
        name: name,
        email: email,
        photoPath: photoPath,
      );
    }

    notifyListeners();
  }

  // ===================== Sair =====================
  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    notifyListeners();
  }

  // ===================== Reset de senha (Firebase) =====================
  Future<void> sendReset(String email) => AuthService.sendPasswordReset(email);

  // ===================== Atualizações de perfil =====================

  /// Atualiza nome e, opcionalmente, foto (apenas caminho local).
  Future<void> updateProfile(String name, {String? photoPath}) async {
    final u = _user;
    if (u == null) return;

    await AuthService.updateProfile(u.uid, name, photoPath: photoPath);

    // Atualiza estado local
    _user = UserProfile(
      uid: u.uid,
      name: name,
      email: u.email,
      photoPath: photoPath ?? u.photoPath,
    );

    // Mantém Firestore coerente caso USE_FIREBASE=false tenha sido trocado depois
    if (AuthService.useFirebase) {
      await _fs.collection('users').doc(u.uid).set({
        'name': name,
        if (photoPath != null) 'photoPath': photoPath,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    notifyListeners();
  }

  /// Atualiza o e-mail do usuário.
  /// No modo local, o uid também muda (uid == email).
  Future<void> updateEmail(String newEmail) async {
    final u = _user;
    if (u == null) return;

    await AuthService.updateEmail(u.uid, newEmail);

    _user = UserProfile(
      uid: AuthService.useFirebase ? u.uid : newEmail, // local: uid == novo email
      name: u.name,
      email: newEmail,
      photoPath: u.photoPath,
    );

    if (AuthService.useFirebase) {
      await _fs.collection('users').doc(_user!.uid).set({
        'email': newEmail,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    notifyListeners();
  }

  /// Atualiza a senha. No modo local, alteramos em SharedPreferences.
  Future<void> updatePassword(String newPassword) async {
    final u = _user;
    if (u == null) return;

    if (AuthService.useFirebase) {
      await AuthService.updatePassword(newPassword);
    } else {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('users') ?? '{}';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rec = map[u.email];
      if (rec == null) {
        throw Exception('Usuário local não encontrado');
      }
      rec['password'] = newPassword;
      map[u.email] = rec;
      await sp.setString('users', jsonEncode(map));
    }
  }

  /// Exclui conta (Auth + dados). Sai e limpa estado.
  Future<void> deleteAccount() async {
    final u = _user;
    if (u == null) return;

    await AuthService.deleteAccount(u.uid, u.email);
    _user = null;
    notifyListeners();
  }
}
