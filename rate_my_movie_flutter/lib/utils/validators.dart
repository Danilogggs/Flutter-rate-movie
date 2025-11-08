final _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
// senha: mínimo 6, letras e números opcionais (refinável)
final _passwordRegex = RegExp(r'^.{6,}$');

String? validateEmail(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'E-mail é obrigatório';
  if (!_emailRegex.hasMatch(v)) return 'E-mail inválido';
  return null;
}

String? validatePassword(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Senha é obrigatória';
  if (!_passwordRegex.hasMatch(v)) return 'Senha deve ter pelo menos 6 caracteres';
  return null;
}

String? validateRequired(String? value, {String fieldLabel = 'Campo'}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return '$fieldLabel é obrigatório';
  return null;
}
