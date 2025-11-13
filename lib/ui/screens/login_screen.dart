import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticate = context.watch<AuthProvider>();
    final email = TextEditingController();
    final password = TextEditingController();
    final form = GlobalKey<FormState>();

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
                    key: form,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (v) =>
                              v != null && v.length >= 6 ? null : 'Min 6 chars',
                        ),
                        const SizedBox(height: 16),
                        if (authenticate.error != null)
                          Text(
                            authenticate.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        NeonButton(
                          label: authenticate.loading ? 'Logging in…' : 'Login',
                          onPressed: authenticate.loading
                              ? null
                              : () async {
                                  if (form.currentState!.validate()) {
                                    await context.read<AuthProvider>().signIn(
                                      email.text.trim(),
                                      password.text.trim(),
                                    );
                                    if (context.mounted &&
                                        context.read<AuthProvider>().user !=
                                            null) {
                                      context.go('/home');
                                    }
                                  }
                                },
                        ),
                        TextButton(
                          onPressed: authenticate.loading
                              ? null
                              : () async {
                                  if (form.currentState!.validate()) {
                                    await context.read<AuthProvider>().signUp(
                                      email.text.trim(),
                                      password.text.trim(),
                                    );
                                    if (context.mounted &&
                                        context.read<AuthProvider>().user !=
                                            null) {
                                      context.go('/home');
                                    }
                                  }
                                },
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
