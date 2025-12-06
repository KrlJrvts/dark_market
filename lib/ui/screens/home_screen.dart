import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../widgets/auction_tile.dart';
import '../widgets/dark_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuctionProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Active auctions', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: p.error != null
          ? Center(
        child: Text(
          p.error!,
          style: TextStyle(color: scheme.error),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: p.auctions.length,
        itemBuilder: (_, i) => AuctionTile(auction: p.auctions[i]),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 0),
    );
  }
}