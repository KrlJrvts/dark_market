import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/auction_provider.dart';
import '../widgets/neon_button.dart';

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
      setState(() {}); // UI-only update inside this screen is OK; app state is in Providers
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final auctions = context.watch<AuctionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create auction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v==null||v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF52FF00), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null ? const Text('Tap to take photo') : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _startPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Starting price (EUR)'),
              validator: (v) => int.tryParse(v??'')==null ? 'Enter a number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _buyout,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Buy out price (EUR)'),
              validator: (v) => int.tryParse(v??'')==null ? 'Enter a number' : null,
            ),
            const SizedBox(height: 16),
            NeonButton(
              label: auctions.loading ? 'Saving…' : 'Place auction',
              onPressed: auctions.loading ? null : () async {
                if (!_form.currentState!.validate()) return;
                final sellerId = auth.user?.uid ?? 'anon';
                await context.read<AuctionProvider>().createAuction(
                  title: _title.text.trim(),
                  sellerId: sellerId,
                  startPrice: int.parse(_startPrice.text),
                  buyout: int.parse(_buyout.text),
                  imageFile: _image,
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
            if (auctions.error != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(auctions.error!, style: const TextStyle(color: Colors.red)),
            )
          ]),
        ),
      ),
    );
  }
}