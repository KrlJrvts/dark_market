import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    final authState = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Future<void> doLogin() async {
      if (!_form.currentState!.validate()) return;
      final ok = await ref.read(authProvider.notifier).signIn(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!context.mounted) return;
      if (ok) {
        context.go('/home');
      }
    }

    Future<void> doSignup() async {
      if (!_form.currentState!.validate()) return;
      final created = await ref.read(authProvider.notifier).signUp(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!context.mounted) return;
      if (created) {
        context.go('/home');
      }
    }

    final showNoAccountHint = authState.errorCode == 'user-not-found';

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
                  const SizedBox(height: 60),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        ThemedTextField(
                          controller: _email,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        ThemedTextField(
                          controller: _password,
                          hintText: 'Password',
                          obscureText: true,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Login',
                    onPressed: doLogin,
                  ),
                  const SizedBox(height: 12),
                  if (authState.errorMessage != null) ...[
                    Text(
                      authState.errorMessage!,
                      style: TextStyle(
                        color: scheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (showNoAccountHint) ...[
                    Text(
                      'No account yet?',
                      style: TextStyle(color: scheme.secondary),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Sign up',
                      onPressed: doSignup,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
