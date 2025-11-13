import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String label; final VoidCallback? onPressed; final Color color;
  const NeonButton({super.key, required this.label, required this.onPressed, this.color = const Color(0xFFB041FF)});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: color.withOpacity(0.6), blurRadius: 16, spreadRadius: 0),
      ]),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}