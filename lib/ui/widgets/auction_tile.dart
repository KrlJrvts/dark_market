import 'package:flutter/material.dart';
import '../../data/models/auction.dart';
import 'package:go_router/go_router.dart';

class AuctionTile extends StatelessWidget {
  final Auction auction;

  const AuctionTile({super.key, required this.auction});

  // Design colors from the image
  static const Color brightGreen = Color(0xFF39FF14);   // Border color
  static const Color tealCyan = Color(0xFF00E5CC);      // Bell icon, highest bid, seller
  static const Color magentaPurple = Color(0xFFB041FF); // Item title
  static const Color magentaPink = Color(0xFFFF00FF);   // Buy now price
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color soldRed = Color(0xFFFF0040);       // Bright red for SOLD text

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/view/${auction.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: darkBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: auction.isClosed ? soldRed : brightGreen,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Main card content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Purple title + bell icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          auction.title,
                          style: const TextStyle(
                            color: magentaPurple,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Middle row: Image on left, prices on right
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image or big ? placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: auction.imageUrl != null
                            ? Image.network(
                          auction.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                            : _buildPlaceholder(),
                      ),

                      const SizedBox(width: 16),
                      // Price details on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Highest bid row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Highest bid',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 25,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white38,
                                  ),
                                ),
                                Text(
                                  '${auction.highestBid ?? 0} €',
                                  style: const TextStyle(
                                    color: tealCyan,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Buy now row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Buy now',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  '${auction.buyout} €',
                                  style: const TextStyle(
                                    color: magentaPink,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom: Seller info
                  Row(
                    children: [
                      const Text(
                        'Seller: ',
                        style: TextStyle(
                          color: tealCyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getSellerDisplayName(),
                        style: const TextStyle(
                          color: tealCyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SOLD overlay - shown when auction is closed
            if (auction.isClosed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2, // Slight tilt for dramatic effect
                      child: Text(
                        'SOLD',
                        style: TextStyle(
                          color: soldRed,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: soldRed.withOpacity(0.8),
                              blurRadius: 20,
                            ),
                            Shadow(
                              color: soldRed.withOpacity(0.5),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Big ? placeholder when no image
  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Show ??? if seller has no username
  String _getSellerDisplayName() {
    // Use sellerName if available, otherwise show ???
    if (auction.sellerName != null && auction.sellerName!.isNotEmpty) {
      return auction.sellerName!;
    }
    return '???';
  }
}