import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/auction.dart';
import '../data/services/auction_service.dart';
import '../data/services/storage_service.dart';
import 'service_providers.dart';

part 'auction_provider.g.dart';

/// State class for auctions
class AuctionState {
  final List<Auction> auctions;
  final bool loading;
  final String? error;

  const AuctionState({
    this.auctions = const [],
    this.loading = false,
    this.error,
  });

  AuctionState copyWith({
    List<Auction>? auctions,
    bool? loading,
    String? Function()? error,
  }) {
    return AuctionState(
      auctions: auctions ?? this.auctions,
      loading: loading ?? this.loading,
      error: error != null ? error() : this.error,
    );
  }
}

/// Stream provider that watches all auctions from Firestore
/// This automatically updates when auctions change in the database
@riverpod
Stream<List<Auction>> auctionsStream(AuctionsStreamRef ref) {
  final auctionService = ref.watch(auctionServiceProvider);
  return auctionService.watchAll();
}

/// Provider for auction state that combines the stream with loading/error states
@riverpod
class Auctions extends _$Auctions {
  AuctionService get _auctionService => ref.read(auctionServiceProvider);
  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  AuctionState build() {
    // Watch the auctions stream
    final auctionsStream = ref.watch(auctionsStreamProvider);

    return auctionsStream.when(
      data: (auctions) => AuctionState(auctions: auctions, loading: false),
      loading: () => const AuctionState(loading: true),
      error: (error, _) => AuctionState(
        error: error.toString(),
        loading: false,
      ),
    );
  }

  /// Create a new auction with optional image
  Future<void> createAuction({
    required String title,
    required String sellerId,
    String? sellerName,
    required int startPrice,
    required int buyout,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    state = state.copyWith(
      loading: true,
      error: () => null,
    );

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
        sellerName: sellerName,
        highestBid: startPrice,
        highestBidId: '',
        buyout: buyout,
        createdAt: now,
        imageUrl: url,
      );

      await _auctionService.add(auctionItem);

      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to create: $e',
        loading: false,
      );
    }
  }

  /// Place a bid on an auction
  Future<void> placeBid(String id, String bidderId, int amount) async {
    try {
      await _auctionService.placeBid(
        auctionId: id,
        bidderId: bidderId,
        amount: amount,
      );
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to place bid: $e',
      );
    }
  }

  /// Buy out an auction immediately at buyout price
  Future<void> buyOut(String id, String buyerId) async {
    try {
      await _auctionService.buyOut(
        auctionId: id,
        buyerId: buyerId,
      );
    } catch (e) {
      state = state.copyWith(
        error: () => 'Failed to buy out: $e',
      );
      rethrow; // Rethrow so the UI can catch and display the error
    }
  }

  /// Get a specific auction by ID
  Auction? getAuctionById(String id) {
    try {
      return state.auctions.firstWhere((auction) => auction.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Helper provider to get a specific auction by ID
@riverpod
Auction? auctionById(AuctionByIdRef ref, String id) {
  final auctionsState = ref.watch(auctionsProvider);
  try {
    return auctionsState.auctions.firstWhere((auction) => auction.id == id);
  } catch (e) {
    return null;
  }
}
