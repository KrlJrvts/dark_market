import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class DarkBottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const DarkBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.3),
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
              onTap: () => _handleSignOut(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    // With Riverpod, stream subscriptions are automatically managed
    // No need to manually cancel streams
    await ref.read(authProvider.notifier).signOut();
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
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? scheme.secondary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.secondary,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: scheme.secondary.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: scheme.secondary,
          size: 26,
        ),
      ),
    );
  }
}