import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class GameHeaderButton extends StatelessWidget {
  final Key? controlKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color accentColor;
  final double size;

  const GameHeaderButton({
    super.key,
    this.controlKey,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accentColor = const Color(0xFFF0B95C),
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: controlKey,
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC1A0A0C),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: accentColor.withValues(alpha: 0.82)),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 8)],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 19),
          color: Colors.white,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class OrnateGameFrame extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;
  final Color accentColor;
  final Color backgroundColor;

  const OrnateGameFrame({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(12),
    this.accentColor = AppTheme.accentColor,
    this.backgroundColor = const Color(0xD91B1110),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, const Color(0xF0180B09), backgroundColor],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha: 0.16), blurRadius: 10),
          const BoxShadow(
            color: Color(0xA6000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _FramePainter(accentColor)),
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  BrushTitle(title!, color: accentColor, compact: true),
                  const SizedBox(height: 8),
                ],
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BrushTitle extends StatelessWidget {
  final String text;
  final Color color;
  final bool compact;
  final TextAlign textAlign;

  const BrushTitle(
    this.text, {
    super.key,
    this.color = Colors.white,
    this.compact = false,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.018,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: 'STKaiti',
              fontSize: compact ? 24 : 42,
              fontWeight: FontWeight.w900,
              letterSpacing: compact ? 2 : 4,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = compact ? 4 : 7
                ..color = const Color(0xFF35100E),
            ),
          ),
          Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: 'STKaiti',
              fontSize: compact ? 24 : 42,
              fontWeight: FontWeight.w900,
              letterSpacing: compact ? 2 : 4,
              color: color,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.85), blurRadius: 15),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertDiamond extends StatelessWidget {
  final bool completed;
  final double size;

  const AlertDiamond({super.key, this.completed = false, this.size = 27});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: completed ? const Color(0xFF268B65) : const Color(0xFFE44324),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFFFD5A3), width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5)],
        ),
        child: Transform.rotate(
          angle: -0.785398,
          child: Icon(
            completed ? Icons.check : Icons.priority_high,
            color: Colors.white,
            size: size * 0.65,
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final Color color;

  _FramePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const inset = 5.0;
    canvas.drawRect(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - inset * 2,
        size.height - inset * 2,
      ),
      paint,
    );
    for (final offset in [
      const Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ]) {
      canvas.drawCircle(offset, 4, paint..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.color != color;
}
