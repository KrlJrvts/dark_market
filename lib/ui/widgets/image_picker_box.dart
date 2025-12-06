import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerBox extends StatelessWidget {
  final File? imageFile;
  final String? networkImageUrl;
  final VoidCallback onTap;
  final Widget placeholder;
  final double height;

  const ImagePickerBox({
    super.key,
    this.imageFile,
    this.networkImageUrl,
    required this.onTap,
    required this.placeholder,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.primary, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover, width: double.infinity);
    }
    if (networkImageUrl != null) {
      return Image.network(networkImageUrl!, fit: BoxFit.cover, width: double.infinity);
    }
    return placeholder;
  }
}