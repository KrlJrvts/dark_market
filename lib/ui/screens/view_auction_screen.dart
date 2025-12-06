import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/auction_provider.dart';
import '../../data/models/auction.dart';
import '../widgets/dark_bottom_nav_bar.dart';
import '../widgets/themed_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/content_card.dart';
import '../../state/auth_provider.dart';

class ViewAuctionScreen extends StatefulWidget {
  final String id;

  const ViewAuctionScreen({super.key, required this.id});

  @override
  State<ViewAuctionScreen> createState() => _ViewAuctionScreenState();
}

class _ViewAuctionScreenState extends State<ViewAuctionScreen> {
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
    final p = context.watch<AuctionProvider>();
    final Auction a = p.auctions.firstWhere(
          (e) => e.id == widget.id,
      orElse: () => p.auctions.first,
    );

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
              // SOLD badge
              if (isSold)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Text(
                    'SOLD',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: a.imageUrl != null
                      ? Image.network(
                    a.imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: scheme.surfaceContainerLowest,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: scheme.secondary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Highest bid: ${a.highestBid ?? 0} EUR',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.secondary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (a.buyout > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.tertiary, width: 1.5),
                      ),
                      child: Text(
                        'Buyout: ${a.buyout} EUR',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ThemedTextField(
                controller: _bidController,
                hintText: 'Your bid',
                enabled: !isSold,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: isSold ? 'Auction ended' : 'Place bid',
                onPressed: isSold
                    ? null
                    : () async {
                  final bid = int.tryParse(_bidController.text.trim());
                  if (bid == null) return;
                  await context.read<AuctionProvider>().placeBid(
                    a.id,
                    context.read<AuthProvider>().user!.uid,
                    bid,
                  );
                },
              ),
              const SizedBox(height: 12),
              // Hide buyout button when sold
              if (a.buyout > 0 && !isSold)
                PrimaryButton(
                  label: 'Buyout now',
                  variant: ButtonVariant.tertiary,
                  onPressed: () async {
                    await context.read<AuctionProvider>().placeBid(
                      a.id,
                      context.read<AuthProvider>().user!.uid,
                      a.buyout,
                    );
                  },
                ),
              const SizedBox(height: 16),
              Text(
                'Created: ${DateFormat('dd.MM.yyyy HH:mm').format(a.createdAt.toLocal())}',
                style: textTheme.bodyMedium?.copyWith(color: scheme.tertiary),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: 0),
    );
  }
}