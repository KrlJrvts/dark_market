import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../widgets/neon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(auth.user?.email ?? 'Unknown user'),
          const SizedBox(height: 12),
          NeonButton(label: 'Sign out', onPressed: () { auth.signOut(); Navigator.pop(context); }),
        ]),
      ),
    );
  }
}