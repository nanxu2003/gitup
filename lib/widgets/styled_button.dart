import 'package:flutter/material.dart';
import 'game_action_button.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDanger;
  final double? width;
  final IconData? icon;

  const StyledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isDanger = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GameActionButton(
      width: width,
      label: text,
      icon: icon,
      onPressed: onPressed,
      style: isDanger
          ? GameActionStyle.danger
          : isPrimary
          ? GameActionStyle.primary
          : GameActionStyle.secondary,
    );
  }
}
