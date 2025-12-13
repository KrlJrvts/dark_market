import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/auction_provider.dart';
import '../widgets/dark_bottom_nav_bar.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/content_card.dart';
import '../widgets/image_picker_box.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _startPrice = TextEditingController();
  final _buyout = TextEditingController();

  File? _image;

  @override
  void dispose() {
    _title.dispose();
    _startPrice.dispose();
    _buyout.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (x != null) {
      setState(() {
        _image = File(x.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create auction',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 24,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ContentCard(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                ThemedTextField(
                  controller: _title,
                  hintText: 'Name',
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                ImagePickerBox(
                  imageFile: _image,
                  onTap: _pickImage,
                  placeholder: _buildPlaceholder(scheme, textTheme),
                ),
                const SizedBox(height: 16),
                ThemedTextField(
                  controller: _startPrice,
                  hintText: 'Start price',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                ThemedTextField(
                  controller: _buyout,
                  hintText: 'Buyout price',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final buyout = int.tryParse(v);
                    final startPrice = int.tryParse(_startPrice.text.trim());
                    if (buyout == null) return 'Invalid number';
                    if (startPrice != null && buyout < startPrice) {
                      return 'Must be bigger than start price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create auction',
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;

                    await ref.read(auctionsProvider.notifier).createAuction(
                      title: _title.text.trim(),
                      sellerId: authState.user!.uid,
                      sellerName: authState.user!.displayName,
                      startPrice: int.parse(_startPrice.text.trim()),
                      buyout: int.parse(_buyout.text.trim()),
                      imageFile: _image,
                    );

                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildPlaceholder(ColorScheme scheme, TextTheme textTheme) {
    return Container(
      color: scheme.surfaceContainerLowest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: scheme.secondary, size: 40),
            const SizedBox(height: 8),
            Text(
              'Tap to add photo',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}