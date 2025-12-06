import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/storage_service.dart';
import '../../state/auth_provider.dart';
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (user == null) {
      return Scaffold(
        backgroundColor: scheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit profile',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 24,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.secondary, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(color: scheme.secondary, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    color: scheme.secondary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.secondary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _localImageFile != null
                        ? Image.file(
                            _localImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : (user.photoURL != null
                              ? Image.network(
                                  user.photoURL!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : _buildImagePlaceholder(scheme)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: scheme.secondary, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'New password',
                  hintStyle: TextStyle(
                    color: scheme.secondary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: scheme.secondary, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  hintStyle: TextStyle(
                    color: scheme.secondary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final pass = _passwordController.text.trim();
                  final confirm = _confirmPasswordController.text.trim();

                  if (pass.isNotEmpty && pass != confirm) {
                    _showSnack('Passwords do not match');
                    return;
                  }

                  // Update name if provided
                  if (name.isNotEmpty) {
                    await auth.updateName(name);
                  }

                  // Update password if provided
                  if (pass.isNotEmpty) {
                    await auth.updatePassword(pass);
                  }

                  // For photo: you would need to upload the file first using StorageService
                  // then call auth.updatePhoto(url)
                  // Note: StorageService only has uploadAuctionImage, you may need to add
                  // a method for profile images, or reuse it like:
                  if (_localImageFile != null) {
                    final storageService = context.read<StorageService>();
                    final url = await storageService.uploadAuctionImage(
                      file: _localImageFile,
                      userId: user.uid,
                    );
                    await auth.updatePhoto(url);
                  }
                  if (!mounted) return;
                  _showSnack('Profile updated');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: scheme.primary.withOpacity(0.6),
                  elevation: 10,
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (!mounted) return;
                  context.go('/');
                },
                child: Text(
                  'Sign out',
                  style: TextStyle(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.bold,
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

  Widget _buildImagePlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceVariant,
      child: Center(
        child: Icon(Icons.person, size: 64, color: scheme.secondary),
      ),
    );
  }
}
