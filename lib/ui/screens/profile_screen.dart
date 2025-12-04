import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auction_provider.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/dark_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _localImageFile;

  // Design colors
  static const Color brightGreen = Color(0xFF39FF14);
  static const Color magentaPink = Color(0xFFFF00FF);
  static const Color darkBackground = Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
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
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _localImageFile = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.black,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: brightGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          // GREEN FRAME AROUND ALL PAGE ELEMENTS
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: brightGreen,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: brightGreen, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    color: brightGreen.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Image picker area - mystery box style
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: darkBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: brightGreen, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _localImageFile != null
                        ? Image.file(_localImageFile!, fit: BoxFit.cover, width: double.infinity)
                        : (user.photoURL != null
                        ? Image.network(user.photoURL!, fit: BoxFit.cover, width: double.infinity)
                        : _buildImagePlaceholder()),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // New password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: brightGreen, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'New password',
                  hintStyle: TextStyle(
                    color: brightGreen.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm new password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: brightGreen, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  hintStyle: TextStyle(
                    color: brightGreen.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brightGreen, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Update button - bright green
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.loading
                      ? null
                      : () async {
                    final name = _nameController.text.trim();
                    final pass = _passwordController.text.trim();
                    final confirm = _confirmPasswordController.text.trim();

                    if (name.isNotEmpty && name != user.displayName) {
                      final ok = await auth.updateName(name);
                      if (!ok) {
                        _showSnack(auth.errorMessage ?? 'Failed to update name');
                        return;
                      }
                    }

                    if (pass.isNotEmpty || confirm.isNotEmpty) {
                      if (pass != confirm) {
                        _showSnack('New password and confirmation do not match');
                        return;
                      }
                      if (pass.length < 6) {
                        _showSnack('Password must be at least 6 characters');
                        return;
                      }
                      final ok = await auth.updatePassword(pass);
                      if (!ok) {
                        _showSnack(auth.errorMessage ?? 'Failed to change password');
                        return;
                      }
                    }

                    _showSnack('Profile updated');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brightGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    auth.loading ? 'Updating…' : 'Update',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Delete button - magenta pink
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.loading
                      ? null
                      : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: brightGreen, width: 2),
                        ),
                        title: const Text(
                          'Delete account',
                          style: TextStyle(color: brightGreen),
                        ),
                        content: const Text(
                          'Are you sure? This cannot be undone.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: magentaPink),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final ok = await auth.deleteAccount();
                    if (!ok) {
                      _showSnack(auth.errorMessage ?? 'Failed to delete account');
                      return;
                    }

                    if (!mounted) return;
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magentaPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 2),
    );
  }

  // Placeholder with mystery box style
  Widget _buildImagePlaceholder() {
    return Container(
      color: darkBackground,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 8),
            Text(
              'Tap to select photo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}