import 'package:flutter/material.dart';
import '../../data/models/auction.dart';
import 'package:go_router/go_router.dart';

class AuctionTile extends StatelessWidget {
  final Auction auction;

  const AuctionTile({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push('/view/${auction.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: auction.isClosed ? scheme.error : scheme.secondary,
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
                  // Top row: Purple title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          auction.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: scheme.primary,
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
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(scheme),
                        )
                            : _buildPlaceholder(scheme),
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
                                Text(
                                  'Highest bid',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.7),
                                    fontSize: 25,
                                    decoration: TextDecoration.underline,
                                    decorationColor: scheme.onSurface.withValues(alpha: 0.38),
                                  ),
                                ),
                                Text(
                                  '${auction.highestBid ?? 0} €',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: scheme.secondary,
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
                                Text(
                                  'Buy now',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.7),
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  '${auction.buyout} €',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: scheme.tertiary,
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
                      Text(
                        'Seller: ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getSellerDisplayName(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.secondary,
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
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2, // Slight tilt for dramatic effect
                      child: Text(
                        'SOLD',
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: scheme.error.withValues(alpha: 0.8),
                              blurRadius: 20,
                            ),
                            Shadow(
                              color: scheme.error.withValues(alpha: 0.5),
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
  Widget _buildPlaceholder(ColorScheme scheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.5),
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