import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../widgets/auction_tile.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuctionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Active auctions'), actions: [
        IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline)),
      ]),
      body: p.error != null
          ? Center(child: Text(p.error!))
          : ListView.builder(
        itemCount: p.auctions.length,
        itemBuilder: (_, i) => AuctionTile(auction: p.auctions[i]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}