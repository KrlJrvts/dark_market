import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/storage_service.dart';
import '../../state/auth_provider.dart';
import '../widgets/dark_bottom_nav_bar.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/content_card.dart';
import '../widgets/image_picker_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
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
    _currentPasswordController.dispose();  // ADD THIS
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

    if (user == null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
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
        child: ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ThemedTextField(controller: _nameController, hintText: 'Name'),
              const SizedBox(height: 16),
              ImagePickerBox(
                imageFile: _localImageFile,
                networkImageUrl: user.photoURL,
                onTap: _pickImage,
                placeholder: _buildImagePlaceholder(scheme),
              ),
              const SizedBox(height: 16),
              ThemedTextField(
                controller: _currentPasswordController,
                hintText: 'Current password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ThemedTextField(
                controller: _passwordController,
                hintText: 'New password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ThemedTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save changes',
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final currentPass = _currentPasswordController.text.trim();  // ADD THIS
                  final pass = _passwordController.text.trim();
                  final confirm = _confirmPasswordController.text.trim();

                  if (pass.isNotEmpty && pass != confirm) {
                    _showSnack('Passwords do not match');
                    return;
                  }

                  // ADD: Validate current password is provided when changing password
                  if (pass.isNotEmpty && currentPass.isEmpty) {
                    _showSnack('Please enter your current password');
                    return;
                  }

                  final storageService = context.read<StorageService>();

                  if (name.isNotEmpty) {
                    await auth.updateName(name);
                  }

                  // UPDATED: Pass current password for re-authentication
                  if (pass.isNotEmpty) {
                    final passwordUpdated = await auth.updatePassword(
                      pass,
                      currentPassword: currentPass,  // PASS CURRENT PASSWORD
                    );
                    if (!passwordUpdated) {
                      if (!context.mounted) return;
                      _showSnack(auth.errorMessage ?? 'Failed to update password');
                      return;
                    }
                    // Clear password fields on success
                    _currentPasswordController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  }

                  if (_localImageFile != null) {
                    final url = await storageService.uploadAuctionImage(
                      file: _localImageFile,
                      userId: user.uid,
                    );
                    await auth.updatePhoto(url);
                  }
                  if (!context.mounted) return;
                  _showSnack('Profile updated');
                },
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Delete account',
                variant: ButtonVariant.tertiary,
                onPressed: () async {
                  // ADDED: Capture authProvider BEFORE any async operations
                  final authProvider = context.read<AuthProvider>();

                  final confirmed =
                      await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete account?'),
                          content: const Text(
                            'This will permanently delete your account and data. This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (!confirmed) return;

                  final ok = await authProvider
                      .deleteAccount(); // CHANGED: Use captured reference
                  if (!context.mounted) return;

                  if (ok) {
                    context.go('/');
                  } else {
                    final msg =
                        authProvider
                            .errorMessage ?? // CHANGED: Use captured reference
                        'Failed to delete account';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
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
      color: scheme.surfaceContainerLowest,
      child: Center(
        child: Icon(Icons.person, size: 64, color: scheme.secondary),
      ),
    );
  }
}
