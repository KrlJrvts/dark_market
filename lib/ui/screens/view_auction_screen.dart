import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../../data/models/auction.dart';
import '../widgets/dark_bottom_nav_bar.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_theme.dart';

class ViewAuctionScreen extends StatefulWidget {
  final String id;

  const ViewAuctionScreen({super.key, required this.id});

  @override
  State<ViewAuctionScreen> createState() => _ViewAuctionScreenState();
}

class _ViewAuctionScreenState extends State<ViewAuctionScreen> {
  late TextEditingController _bidController;

  // Design colors
  static const Color brightGreen = Color(0xFF39FF14);
  static const Color tealCyan = Color(0xFF00E5CC);
  static const Color magentaPurple = Color(0xFFB041FF);
  static const Color magentaPink = Color(0xFFFF00FF);
  static const Color darkBackground = Color(0xFF0A0A0A);

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

    // Initialize bid controller with suggested bid
    if (_bidController.text.isEmpty) {
      _bidController.text = ((a.highestBid ?? 0) + 10).toString();
    }

    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'View auction',
          style: TextStyle(
            color: brightGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          // GREEN FRAME AROUND ALL PAGE ELEMENTS
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: brightGreen,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item title - purple
              Text(
                a.title,
                style: const TextStyle(
                  color: magentaPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Image area
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: a.imageUrl != null
                      ? Image.network(
                    a.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                      : _buildPlaceholder(),
                ),
              ),

              const SizedBox(height: 20),

              // Highest bid row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Highest bid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${a.highestBid ?? 0} €',
                    style: const TextStyle(
                      color: tealCyan,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Buy out row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Buy out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${a.buyout} €',
                    style: const TextStyle(
                      color: magentaPink,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Buy out now button - magenta filled
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: a.isClosed
                      ? null
                      : () async {
                    final auth = context.read<AuthProvider>();
                    final bidderId = auth.user!.uid;
                    await p.placeBid(a.id, bidderId, a.buyout);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: magentaPink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    a.isClosed ? 'Sold' : 'Buy out now',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Inline bid input and button - shown when auction is not closed
              if (!a.isClosed) ...[
                const SizedBox(height: 16),

                // Bid input field - cyan outlined
                TextField(
                  controller: _bidController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: tealCyan, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Place your bid',
                    hintStyle: TextStyle(
                      color: tealCyan.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixText: '€',
                    suffixStyle: const TextStyle(color: tealCyan, fontSize: 18),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: tealCyan, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: tealCyan, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bid button - cyan filled
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _placeBid(context, a, p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Bid',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],

              // Show SOLD message if closed
              if (a.isClosed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 24),
                  alignment: Alignment.center,
                  child: Text(
                    'SOLD',
                    style: TextStyle(
                      color: const Color(0xFFFF0040),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFF0040).withOpacity(0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DarkBottomNavBar(currentIndex: -1),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _placeBid(BuildContext context, Auction a, AuctionProvider p) async {
    final v = int.tryParse(_bidController.text);
    if (v == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number!'),
        ),
      );
      return;
    }

    if (v <= (a.highestBid ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be higher than ${a.highestBid ?? 0} €'),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final bidderId = auth.user!.uid;
    await p.placeBid(a.id, bidderId, v);
  }
}