import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/auction_provider.dart';
import '../../state/auth_provider.dart';

class DarkBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const DarkBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  // Colors matching your design
  static const Color tealCyan = Color(0xFF00E5CC);
  static const Color brightGreen = Color(0xFF39FF14);
  static const Color darkBackground = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: darkBackground,
        border: Border(
          top: BorderSide(
            color: brightGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1) Home
            _NavButton(
              icon: Icons.home_outlined,
              isSelected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            // 2) Create Auction
            _NavButton(
              icon: Icons.add_box_outlined,
              isSelected: currentIndex == 1,
              onTap: () => context.go('/create'),
            ),
            // 3) Profile
            _NavButton(
              icon: Icons.edit_outlined,
              isSelected: currentIndex == 2,
              onTap: () => context.go('/profile'),
            ),
            // 4) Sign Out
            _NavButton(
              icon: Icons.logout_outlined,
              isSelected: false,
              onTap: () => _handleSignOut(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    // Cancel Firestore listeners BEFORE signing out
    final auctionProvider = context.read<AuctionProvider>();
    auctionProvider.cancelStream();

    await context.read<AuthProvider>().signOut();
    if (context.mounted) {
      context.go('/');
    }
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color brightGreen = Color(0xFF39FF14);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? brightGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: brightGreen,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: brightGreen.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: brightGreen,
          size: 26,
        ),
      ),
    );
  }
}