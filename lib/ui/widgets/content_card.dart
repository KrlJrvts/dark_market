import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ContentCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.secondary, width: 2),
      ),
      child: child,
    );
  }
}