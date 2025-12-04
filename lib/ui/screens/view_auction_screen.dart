import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../../data/models/auction.dart';
import '../widgets/neon_button.dart';
import '../../state/auth_provider.dart';

class ViewAuctionScreen extends StatelessWidget {
  final String id;

  const ViewAuctionScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuctionProvider>();
    final Auction a = p.auctions.firstWhere(
          (e) => e.id == id,
      orElse: () => p.auctions.first,
    );

    final controller = TextEditingController(
      text: (((a.highestBid ?? 0) + 10)).toString(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE
            if (a.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  a.imageUrl!,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 180,
                alignment: Alignment.center,
                child: const Icon(Icons.image, size: 64),
              ),

            const SizedBox(height: 12),

            // DETAILS
            Text('Highest bid:  ${a.highestBid ?? 0} €'),
            const SizedBox(height: 4),
            Text('Buy out:      ${a.buyout} €'),



            const SizedBox(height: 12),

            // BUYOUT BUTTON
            NeonButton(
              label: a.isClosed ? 'Sold' : 'Buy out now',
              onPressed: a.isClosed
                  ? null
                  : () async {
                final auth = context.read<AuthProvider>();
                final bidderId = auth.user!.uid;

                await p.placeBid(a.id, bidderId, a.buyout);
              },
            ),

            const SizedBox(height: 8),


            if (!a.isClosed) ...[
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Place your bid'),
              ),
              const SizedBox(height: 8),
              NeonButton(
                label: 'Bid',
                onPressed: () async {
                  final v = int.tryParse(controller.text);
                  if (v == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Get together and learn numbers!'),
                      ),
                    );
                    return;
                  }

                  final auth = context.read<AuthProvider>();
                  final bidderId = auth.user!.uid;

                  await p.placeBid(a.id, bidderId, v);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
