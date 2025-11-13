import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dark_market/data/models/auction.dart';
import 'package:dark_market/data/services/auction_service.dart';
import 'package:dark_market/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class AuctionProvider extends ChangeNotifier {
  final AuctionService _auctionService;
  final StorageService _storageService;

  AuctionProvider(this._auctionService, this._storageService);

  List<Auction> auctions = [];
  bool loading = false;
  String? error;

  void bindStream() {
    _auctionService.watchAll().listen(
      (data) {
        auctions = data;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> createAuction({
    required String title,
    required String sellerId,
    required int startPrice,
    required int buyout,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      String? url;
      if (imageFile != null || imageBytes != null) {
        url = await _storageService.uploadAuctionImage(
          file: imageFile,
          bytes: imageBytes,
          userId: sellerId,
        );
      }

      final now = DateTime.now();
      final auctionItem = Auction(
        id: '',
        title: title,
        sellerId: sellerId,
        highestBid: startPrice,
        highestBidId: '',
        buyout: buyout,
        createdAt: now,
      );
      final id = await _auctionService.add(auctionItem);
    } catch (e) {
      error = 'Failed to create: $e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> placeBid(String id, String bidderId, int amount) =>
      _auctionService.placeBid(
        auctionId: id,
        bidderId: bidderId,
        amount: amount,
      );
}
