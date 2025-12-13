// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auctionsStreamHash() => r'bcaec2776da9e74744ca08a7fce04faec9fab1e2';

/// Stream provider that watches all auctions from Firestore
/// This automatically updates when auctions change in the database
///
/// Copied from [auctionsStream].
@ProviderFor(auctionsStream)
final auctionsStreamProvider =
    AutoDisposeStreamProvider<List<Auction>>.internal(
      auctionsStream,
      name: r'auctionsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$auctionsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuctionsStreamRef = AutoDisposeStreamProviderRef<List<Auction>>;
String _$auctionByIdHash() => r'1429b30e76ff000db5d7b7533a80ca850f9f786c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Helper provider to get a specific auction by ID
///
/// Copied from [auctionById].
@ProviderFor(auctionById)
const auctionByIdProvider = AuctionByIdFamily();

/// Helper provider to get a specific auction by ID
///
/// Copied from [auctionById].
class AuctionByIdFamily extends Family<Auction?> {
  /// Helper provider to get a specific auction by ID
  ///
  /// Copied from [auctionById].
  const AuctionByIdFamily();

  /// Helper provider to get a specific auction by ID
  ///
  /// Copied from [auctionById].
  AuctionByIdProvider call(String id) {
    return AuctionByIdProvider(id);
  }

  @override
  AuctionByIdProvider getProviderOverride(
    covariant AuctionByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'auctionByIdProvider';
}

/// Helper provider to get a specific auction by ID
///
/// Copied from [auctionById].
class AuctionByIdProvider extends AutoDisposeProvider<Auction?> {
  /// Helper provider to get a specific auction by ID
  ///
  /// Copied from [auctionById].
  AuctionByIdProvider(String id)
    : this._internal(
        (ref) => auctionById(ref as AuctionByIdRef, id),
        from: auctionByIdProvider,
        name: r'auctionByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$auctionByIdHash,
        dependencies: AuctionByIdFamily._dependencies,
        allTransitiveDependencies: AuctionByIdFamily._allTransitiveDependencies,
        id: id,
      );

  AuctionByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(Auction? Function(AuctionByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: AuctionByIdProvider._internal(
        (ref) => create(ref as AuctionByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Auction?> createElement() {
    return _AuctionByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuctionByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuctionByIdRef on AutoDisposeProviderRef<Auction?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AuctionByIdProviderElement extends AutoDisposeProviderElement<Auction?>
    with AuctionByIdRef {
  _AuctionByIdProviderElement(super.provider);

  @override
  String get id => (origin as AuctionByIdProvider).id;
}

String _$auctionsHash() => r'db62e8e4b7a1035d798f245572ac4793b9e1f691';

/// Provider for auction state that combines the stream with loading/error states
///
/// Copied from [Auctions].
@ProviderFor(Auctions)
final auctionsProvider =
    AutoDisposeNotifierProvider<Auctions, AuctionState>.internal(
      Auctions.new,
      name: r'auctionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$auctionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Auctions = AutoDisposeNotifier<AuctionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
