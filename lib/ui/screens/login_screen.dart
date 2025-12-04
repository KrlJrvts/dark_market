import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../state/auction_provider.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_theme.dart';

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
      if (ok) {
        context.read<AuctionProvider>().bindStream();
        context.go('/home');
      }
    }

    Future<void> _doSignup() async {
      if (!_form.currentState!.validate()) return;
      final created = await context.read<AuthProvider>().signUp(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (!mounted) return;
      if (created) {
        context.read<AuctionProvider>().bindStream();
        context.go('/home');
      }
    }

    final showNoAccountHint = auth.errorCode == 'user-not-found';

    // Colors from the design
    const Color tealCyan = Color(0xFF00E5CC); // Teal/Cyan for borders and icons
    const Color brightGreen = Color(0xFF39FF14); // Bright green for button
    const Color purpleGlow = Color(0xFFB041FF); // Purple for title

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Title with purple glow effect
                  Text(
                    'Dark',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pacifico', // Use a cursive font, or GoogleFonts.pacifico()
                      fontSize: 56,
                      color: brightGreen,
                      shadows: [
                        Shadow(
                          color: purpleGlow.withOpacity(1.0),
                          blurRadius: 200,
                        ),
                        Shadow(
                          color: purpleGlow.withOpacity(0.8),
                          blurRadius: 200,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Market',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 56,
                      color: brightGreen,
                      shadows: [
                        Shadow(
                          color: purpleGlow.withOpacity(1.0),
                          blurRadius: 200,
                        ),
                        Shadow(
                          color: purpleGlow.withOpacity(0.8),
                          blurRadius: 200,
                        ),
                      ],
                    ),
                  ),



                  const SizedBox(height: 48),

                  // Form
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        // Email field
                        TextFormField(
                          controller: _email,
                          style: const TextStyle(color: tealCyan),
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: TextStyle(color: tealCyan.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.mail_outline, color: tealCyan),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: tealCyan, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: tealCyan, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                          onChanged: (_) => context.read<AuthProvider>().clearError(),
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          style: const TextStyle(color: tealCyan),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: tealCyan.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.lock_outline, color: tealCyan),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: tealCyan, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: tealCyan, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 chars',
                          onChanged: (_) => context.read<AuthProvider>().clearError(),
                        ),

                        const SizedBox(height: 20),

                        // Error messages
                        if (auth.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                          ),

                        if (showNoAccountHint) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'No account found for this email. You can create one now.',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        // Login button - bright green
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: auth.loading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brightGreen,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              auth.loading ? 'Logging in…' : 'Login',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Create account link
                        TextButton(
                          onPressed: auth.loading ? null : _doSignup,
                          child: const Text(
                            'create account',
                            style: TextStyle(
                              color: tealCyan,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Tagline at bottom
                  const Text(
                    'When eBay is too mainstream',
                    style: TextStyle(
                      color: tealCyan,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}