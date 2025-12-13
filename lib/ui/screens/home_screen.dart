import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auction_provider.dart';
import '../widgets/auction_tile.dart';
import '../widgets/dark_bottom_nav_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionState = ref.watch(auctionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Active auctions',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 24,
            fontStyle: FontStyle.italic
          ),
        ),
      ),
      body: auctionState.error != null
          ? Center(
              child: Text(auctionState.error!, style: TextStyle(color: scheme.error)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: auctionState.auctions.length,
              itemBuilder: (_, i) => AuctionTile(auction: auctionState.auctions[i]),
            ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 0),
    );
  }
}
