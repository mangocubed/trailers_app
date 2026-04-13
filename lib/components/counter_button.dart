import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class CounterButton extends StatelessWidget {
  const CounterButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.tooltip,
    this.colorSelected = colorCounter,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final int count;
  final bool isSelected;
  final String tooltip;
  final Color colorSelected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          minimumSize: Size.zero,
          fixedSize: Size.fromWidth(40),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        ),
        onPressed: onPressed,
        child: Column(
          spacing: 4,
          children: [
            icon,
            Text(
              NumberFormat.compact().format(count),
              style: TextStyle(color: isSelected ? colorSelected : colorCounter, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
