import 'package:flutter/material.dart';
import '../app/app_theme.dart';

class StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color? color;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppTheme.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maxValue > 0 ? value / maxValue : 0,
                backgroundColor: const Color(0xFF333333),
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: barColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
