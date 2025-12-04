import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../state/auction_provider.dart';
import '../../theme/app_theme.dart';
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

  // Design colors
  static const Color brightGreen = Color(0xFF39FF14);
  static const Color magentaPink = Color(0xFFFF00FF);
  static const Color darkBackground = Color(0xFF0A0A0A);

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

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Create auction',
          style: TextStyle(
            color: brightGreen,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const SizedBox(height: 8),

              // Name field
              TextFormField(
                controller: _title,
                style: const TextStyle(color: brightGreen),
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 16),

              // Image picker area - large mystery box style
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
                    child: _image == null
                        ? _buildImagePlaceholder()
                        : Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Starting price field
              TextFormField(
                controller: _startPrice,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: brightGreen),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Starting price',
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
              ),

              const SizedBox(height: 16),

              // Buy out price field
              TextFormField(
                controller: _buyout,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: brightGreen),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Buy out price',
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
              ),

              const SizedBox(height: 24),

              // Place auction button - bright magenta/pink
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: auctions.loading
                      ? null
                      : () async {
                    if (!_form.currentState!.validate()) return;
                    final sellerId = auth.user?.uid ?? 'anon';
                    final sellerName = auth.user?.displayName;  // <-- ADD THIS

                    await context.read<AuctionProvider>().createAuction(
                      title: _title.text.trim(),
                      sellerId: sellerId,
                      sellerName: sellerName,  // <-- ADD THIS
                      startPrice: int.parse(_startPrice.text),
                      buyout: int.parse(_buyout.text),
                      imageFile: _image,
                    );
                    if (context.mounted) context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magentaPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    auctions.loading ? 'Saving…' : 'Place auction',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Error message
              if (auctions.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auctions.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 1),
    );
  }

  // Placeholder with mystery box style "?" icon
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
              'Tap to take photo',
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