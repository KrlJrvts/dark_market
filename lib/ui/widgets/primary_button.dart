import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, tertiary }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.secondary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Color bgColor;
    final Color fgColor;
    switch (variant) {
      case ButtonVariant.primary:
        bgColor = scheme.primary;
        fgColor = scheme.onPrimary;
      case ButtonVariant.secondary:
        bgColor = scheme.secondary;
        fgColor = scheme.onSecondary;
      case ButtonVariant.tertiary:
        bgColor = scheme.tertiary;
        fgColor = scheme.onTertiary;
    }

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: scheme.tertiary.withValues(alpha: 0.6),
        elevation: 10,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}