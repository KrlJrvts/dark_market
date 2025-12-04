import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/auction_tile.dart';
import '../widgets/dark_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuctionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Active auctions',
          style: TextStyle(
            color: Color(0xFF39FF14), // Bright green
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: p.error != null
          ? Center(
        child: Text(
          p.error!,
          style: const TextStyle(color: Colors.red),
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