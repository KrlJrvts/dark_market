import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../state/auction_provider.dart';
import '../widgets/dark_bottom_nav_bar.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});
  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _startPrice = TextEditingController();
  final _buyout = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.camera, maxWidth: 1280, imageQuality: 85);
    if (x != null) {
      _image = File(x.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final auctions = context.watch<AuctionProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Create auction', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _title,
                style: TextStyle(color: scheme.secondary),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover, width: double.infinity)
                        : _buildPlaceholder(scheme, textTheme),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startPrice,
                keyboardType: TextInputType.number,
                style: TextStyle(color: scheme.secondary),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Start price',
                  hintStyle: TextStyle(
                    color: scheme.secondary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buyout,
                keyboardType: TextInputType.number,
                style: TextStyle(color: scheme.secondary),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Buyout price (optional)',
                  hintStyle: TextStyle(
                    color: scheme.secondary.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.secondary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scheme.error, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  if (_image == null) return;

                  await auctions.createAuction(
                    title: _title.text.trim(),
                    sellerId: auth.user!.uid,
                    sellerName: auth.user!.displayName,
                    startPrice: int.parse(_startPrice.text.trim()),
                    buyout: _buyout.text.trim().isEmpty ? 0 : int.parse(_buyout.text.trim()),
                    imageFile: _image,
                  );

                  if (mounted) {
                    context.go('/home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  shadowColor: scheme.primary.withOpacity(0.6),
                  elevation: 10,
                ),
                child: const Text('Create auction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildPlaceholder(ColorScheme scheme, TextTheme textTheme) {
    return Container(
      color: scheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: scheme.secondary, size: 40),
            const SizedBox(height: 8),
            Text('Tap to add photo', style: textTheme.bodyMedium?.copyWith(color: scheme.secondary)),
          ],
        ),
      ),
    );
  }
}