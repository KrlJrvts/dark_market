import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/auction.dart';
import '../widgets/dark_bottom_nav_bar.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/content_card.dart';

class ViewAuctionScreen extends ConsumerStatefulWidget {
  final String id;

  const ViewAuctionScreen({super.key, required this.id});

  @override
  ConsumerState<ViewAuctionScreen> createState() => _ViewAuctionScreenState();
}

class _ViewAuctionScreenState extends ConsumerState<ViewAuctionScreen> {
  late TextEditingController _bidController;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auctionState = ref.watch(auctionsProvider);
    final auction = ref.watch(auctionByIdProvider(widget.id));

    // Fallback if auction not found
    final Auction a = auction ?? (auctionState.auctions.isNotEmpty
        ? auctionState.auctions.first
        : Auction(
            id: '',
            title: 'Not found',
            sellerId: '',
            buyout: 0,
            createdAt: DateTime.now(),
          ));

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Check if auction is sold (closed or highest bid >= buyout)
    final bool isSold = a.isClosed || (a.buyout > 0 && (a.highestBid ?? 0) >= a.buyout);

    if (_bidController.text.isEmpty) {
      _bidController.text = ((a.highestBid ?? 0) + 10).toString();
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'View auction',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 24,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (a.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    a.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: scheme.surfaceContainerLowest,
                      child: Icon(Icons.broken_image, color: scheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildInfoRow('Seller', a.sellerName ?? 'Unknown', scheme, textTheme),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Current bid',
                '€${a.highestBid ?? 0}',
                scheme,
                textTheme,
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Buyout', '€${a.buyout}', scheme, textTheme),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Posted',
                DateFormat.yMd().add_Hm().format(a.createdAt),
                scheme,
                textTheme,
              ),
              if (isSold) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SOLD',
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!isSold) ...[
                const SizedBox(height: 24),
                ThemedTextField(
                  controller: _bidController,
                  hintText: 'Your bid',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Place bid',
                  onPressed: () async {
                    final authState = ref.read(authProvider);
                    final amount = int.tryParse(_bidController.text.trim());
                    if (amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter valid amount')),
                      );
                      return;
                    }
                    if (amount <= (a.highestBid ?? 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bid must be > €${a.highestBid ?? 0}'),
                        ),
                      );
                      return;
                    }

                    await ref.read(auctionsProvider.notifier).placeBid(
                      widget.id,
                      authState.user!.uid,
                      amount,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bid placed!')),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: -1),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.secondary.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
