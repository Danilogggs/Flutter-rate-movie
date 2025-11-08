import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  File? _photo;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source, maxWidth: 1024);
    if (img == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File(p.join(
      dir.path,
      'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(img.path)}',
    ));
    await File(img.path).copy(dest.path);
    setState(() => _photo = dest);
  }

  Future<void> _showInfoDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Cadastro realizado'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => validateRequired(v, fieldLabel: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Semantics(
                      label: 'Selecionar foto da galeria',
                      button: true,
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: const Text('Foto da galeria'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      label: 'Tirar foto com câmera',
                      button: true,
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        child: const Text('Tirar foto'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Preview redondo
                Center(
                  child: Semantics(
                    label: 'Pré-visualização da foto de perfil',
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _photo != null ? FileImage(_photo!) : null,
                      child: _photo == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Botão Cadastrar',
                  button: true,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            setState(() => _loading = true);
                            try {
                              await context.read<AuthProvider>().register(
                                    _name.text.trim(),
                                    _email.text.trim(),
                                    _password.text.trim(),
                                    photoPath: _photo?.path,
                                  );

                              // Mostra modal de sucesso
                              if (mounted) {
                                await _showInfoDialog(
                                  'Conta criada com sucesso! Faça login para continuar.',
                                );
                              }

                              // Garante que o usuário precise autenticar (caso o register tenha logado)
                              await context.read<AuthProvider>().signOut();

                              // Navega para a tela de Login e limpa o histórico
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Erro no cadastro'),
                                    content: Text(e.toString()),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
