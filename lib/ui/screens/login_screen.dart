import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_theme.dart';
// If you don't have NeonButton, replace it with an ElevatedButton.
import '../widgets/neon_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Future<void> _doLogin() async {
      if (!_form.currentState!.validate()) return;
      final ok = await context.read<AuthProvider>().signIn(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!mounted) return;
      if (ok) context.go('/home'); // only on confirmed success
      // otherwise: stay on screen, errorMessage already set
    }

    Future<void> _doSignup() async {
      if (!_form.currentState!.validate()) return;
      final created = await context.read<AuthProvider>().signUp(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!mounted) return;
      if (created) context.go('/home'); // forward new user to /home
      // else: show error (e.g., email-already-in-use)
    }

    final showNoAccountHint = auth.errorCode == 'user-not-found';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Dark\nMarket',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      color: AppTheme.neonGreen,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                          onChanged: (_) => context.read<AuthProvider>().clearError(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars',
                          onChanged: (_) => context.read<AuthProvider>().clearError(),
                        ),
                        const SizedBox(height: 16),

                        if (auth.errorMessage != null)
                          Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),

                        if (showNoAccountHint) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'No account found for this email. You can create one now.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],

                        const SizedBox(height: 12),
                        NeonButton(
                          label: auth.loading ? 'Logging in…' : 'Login',
                          onPressed: auth.loading ? null : _doLogin,
                        ),
                        TextButton(
                          onPressed: auth.loading ? null : _doSignup,
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
