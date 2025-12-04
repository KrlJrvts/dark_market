import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auction_provider.dart';
import '../../state/auth_provider.dart';
import '../widgets/neon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _localImageFile; // just for preview if user selects image

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    // user is guaranteed to exist here, because you don't show this page otherwise
    _nameController.text = auth.user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    // OPTIONAL – user never has to do this
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return; // user cancelled – nothing required

    final file = File(picked.path);
    setState(() {
      _localImageFile = file;
    });

    // OPTIONAL: later you can upload and call auth.updatePhoto(url)
    // For now, just local preview is enough to match your drawing.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user; // user already has account to see this page

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Email (read‑only info that user already has account)
                Text(
                  user.email ?? 'Unknown user',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Name field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),

                // Optional avatar/photo area
                GestureDetector(
                  onTap: _pickImage, // user may ignore this completely
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _localImageFile != null
                          ? Image.file(_localImageFile!, fit: BoxFit.cover)
                          : (user.photoURL != null
                          ? Image.network(user.photoURL!, fit: BoxFit.cover)
                          : const Center(
                        child: Icon(Icons.person, size: 64),
                      )),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password fields (optional – only used if filled)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration:
                  const InputDecoration(labelText: 'New password (optional)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Confirm new password (optional)'),
                ),

                const SizedBox(height: 24),

                NeonButton(
                  label: 'Update',
                  onPressed: auth.loading
                      ? null
                      : () async {
                    final name = _nameController.text.trim();
                    final pass = _passwordController.text.trim();
                    final confirm =
                    _confirmPasswordController.text.trim();

                    // 1) Update name only if changed and non‑empty
                    if (name.isNotEmpty && name != user.displayName) {
                      final ok = await auth.updateName(name);
                      if (!ok) {
                        _showSnack(
                            auth.errorMessage ?? 'Failed to update name');
                        return;
                      }
                    }

                    // 2) Update password only if user actually typed something
                    if (pass.isNotEmpty || confirm.isNotEmpty) {
                      if (pass != confirm) {
                        _showSnack(
                            'New password and confirmation do not match');
                        return;
                      }
                      if (pass.length < 6) {
                        _showSnack(
                            'Password must be at least 6 characters');
                        return;
                      }
                      final ok = await auth.updatePassword(pass);
                      if (!ok) {
                        _showSnack(auth.errorMessage ??
                            'Failed to change password');
                        return;
                      }
                    }

                    _showSnack('Profile updated');
                  },
                ),

                const SizedBox(height: 12),

                NeonButton(
                  label: 'Delete account',
                  onPressed: auth.loading
                      ? null
                      : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete account'),
                        content: const Text(
                            'Are you sure? This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final ok = await auth.deleteAccount();
                    if (!ok) {
                      _showSnack(auth.errorMessage ??
                          'Failed to delete account');
                      return;
                    }

                    if (!mounted) return;
                    // After delete, send user back to login (they no longer have a session)
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
                const SizedBox(height: 12),
                NeonButton(
                  label: 'Sign out',
                  onPressed: () async {
                    // Cancel Firestore listeners BEFORE signing out
                    final auctionProvider = context.read<AuctionProvider>();
                    auctionProvider.cancelStream();

                    await auth.signOut();
                    if (!mounted) return;
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}