import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  ImageProvider? _buildImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (file.existsSync()) return FileImage(file);
    } catch (_) {
      // Ignora erros de I/O e cai no avatar padrão
    }
    return null;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text('Tem certeza? Esta ação é permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await context.read<AuthProvider>().deleteAccount();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final imgProvider = _buildImageProvider(user?.photoPath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Foto de perfil de ${user?.name ?? ""}',
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imgProvider,
                child: imgProvider == null ? const Icon(Icons.person, size: 32) : null,
              ),
            ),
            const SizedBox(height: 12),
            Text('Nome: ${user?.name ?? ''}', style: Theme.of(context).textTheme.titleMedium),
            Text('E-mail: ${user?.email ?? ''}'),
            const SizedBox(height: 24),

            // Ações
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
                context.read<AuthProvider>().signOut();
              },
              child: const Text('Sair'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Excluir conta'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
