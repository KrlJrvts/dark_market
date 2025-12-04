import 'package:flutter/material.dart';
import '../../data/models/auction.dart';
import 'package:go_router/go_router.dart';

class AuctionTile extends StatelessWidget {
  final Auction auction; const AuctionTile({super.key, required this.auction});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: auction.imageUrl != null ? CircleAvatar(backgroundImage: NetworkImage(auction.imageUrl!)) : const Icon(Icons.image, size: 32),
        title: Text(auction.title),
        subtitle: Text('Highest: ${auction.highestBid} €  •  Buy out: ${auction.buyout} €'),
        onTap: () => context.push('/view/${auction.id}'),
      ),
    );
  }
}