import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadAuctionImage({
    File? file,
    Uint8List? bytes,
    required String userId,
  }) async {
    try {
      // pick source
      Uint8List? data = bytes;
      if (data == null && !kIsWeb && file != null) {
        data = await file.readAsBytes();
      }
      if (data == null) throw Exception('Provide a File (mobile) or bytes (web).');

      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'auction_images/$userId/$filename';
      final ref = _storage.ref(path);

      final meta = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=604800',
      );

      final snap = await ref.putData(data, meta);
      return snap.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unauthorized': throw Exception('No permission to upload image.');
        case 'canceled':     throw Exception('Upload canceled.');
        default:             throw Exception('Upload failed: ${e.message}');
      }
    }
  }

  Future<void> deleteByUrl(String url) => _storage.refFromURL(url).delete();
}
