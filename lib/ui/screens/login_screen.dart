import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/auction_provider.dart';
import '../../state/auth_provider.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> doLogin() async {
      if (!_form.currentState!.validate()) return;
      final ok = await context.read<AuthProvider>().signIn(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!context.mounted) return;
      if (ok) {
        context.read<AuctionProvider>().bindStream();
        context.go('/home');
      }
    }

    Future<void> doSignup() async {
      if (!_form.currentState!.validate()) return;
      final created = await context.read<AuthProvider>().signUp(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!context.mounted) return;
      if (created) {
        context.read<AuctionProvider>().bindStream();
        context.go('/home');
      }
    }

    final showNoAccountHint = auth.errorCode == 'user-not-found';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Dark',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      fontFamily: 'Pacifico',
                      fontSize: 56,
                      fontWeight: FontWeight.w500,
                      color: scheme.secondary,
                      shadows: [
                        Shadow(
                          color: scheme.primary.withValues(alpha: 1.0),
                          blurRadius: 200,
                        ),
                        Shadow(
                          color: scheme.tertiary.withValues(alpha: 0.8),
                          blurRadius: 300,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Market',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      fontFamily: 'Pacifico',
                      fontSize: 56,
                      fontWeight: FontWeight.w500,
                      color: scheme.secondary,
                      shadows: [
                        Shadow(
                          color: scheme.primary.withValues(alpha: 1.0),
                          blurRadius: 200,
                        ),
                        Shadow(
                          color: scheme.tertiary.withValues(alpha: 0.8),
                          blurRadius: 300,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 72),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        ThemedTextField(
                          controller: _email,
                          hintText: 'Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: scheme.tertiary,
                          ),
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        ThemedTextField(
                          controller: _password,
                          hintText: 'Password',
                          obscureText: true,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: scheme.tertiary,
                          ),
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showNoAccountHint)
                    Text(
                      'No account? Tap Sign up',
                      style: TextStyle(
                        color: scheme.secondary.withValues(alpha: 0.8),
                      ),
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Login',
                    variant: ButtonVariant.primary,
                    onPressed: doLogin,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: doSignup,
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: scheme.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'When eBay is too mainsteram',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.tertiary.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}