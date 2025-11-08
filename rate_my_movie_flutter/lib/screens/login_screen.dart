import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _showErrorDialog(String message) async {
    // Modal acessível: AlertDialog já é lido por TalkBack/VoiceOver
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Não foi possível entrar'),
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

  String _mapAuthError(Object e) {
    final msg = e.toString().toLowerCase();

    // Códigos comuns do FirebaseAuthException
    if (msg.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('wrong-password')) {
      return 'Senha incorreta.';
    }
    if (msg.contains('user-not-found')) {
      return 'Não existe usuário com esse e-mail.';
    }
    if (msg.contains('invalid-email')) {
      return 'E-mail inválido.';
    }
    if (msg.contains('user-disabled')) {
      return 'Usuário desabilitado.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente em alguns minutos.';
    }

    // Modo local (mensagens do nosso AuthService)
    if (msg.contains('e-mail não encontrado')) {
      return 'Não existe usuário com esse e-mail.';
    }
    if (msg.contains('senha incorreta')) {
      return 'Senha incorreta.';
    }

    // Genérico
    return 'Falha ao entrar. Verifique seus dados e tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'voce@exemplo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
                  obscureText: true,
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Botão Entrar',
                  hint: 'Efetuar login',
                  button: true,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_form.currentState!.validate()) return;
                            setState(() => _loading = true);
                            try {
                              await context
                                  .read<AuthProvider>()
                                  .signIn(_email.text.trim(), _password.text.trim());
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/search');
                              }
                            } catch (e) {
                              final nice = _mapAuthError(e);
                              if (mounted) await _showErrorDialog(nice);
                            } finally {
                              if (mounted) setState(() => _loading = false);
                            }
                          },
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot'),
                  child: const Text('Esqueci minha senha'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
