import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/services/auth_service.dart';
import '../data/services/auction_service.dart';
import '../data/services/storage_service.dart';

part 'service_providers.g.dart';

/// Provider for AuthService
/// This is a singleton that stays alive for the entire app lifecycle
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

/// Provider for AuctionService
/// This is a singleton that stays alive for the entire app lifecycle
@riverpod
AuctionService auctionService(AuctionServiceRef ref) {
  return AuctionService();
}

/// Provider for StorageService
/// This is a singleton that stays alive for the entire app lifecycle
@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService();
}
