import 'package:flutter/material.dart';

enum GameSurfaceStyle { lacquer, bronze, parchment, iron }

class GameSurface extends StatelessWidget {
  final Widget child;
  final GameSurfaceStyle style;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final BorderRadiusGeometry borderRadius;

  const GameSurface({
    super.key,
    required this.child,
    this.style = GameSurfaceStyle.lacquer,
    this.padding = const EdgeInsets.all(12),
    this.accentColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? _defaultAccent;
    return Container(
      key: ValueKey('game-surface-${style.name}'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: borderRadius,
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xB3000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _GameSurfacePainter(accent: accent, style: style),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  List<Color> get _gradientColors => switch (style) {
    GameSurfaceStyle.lacquer => const [
      Color(0xEE541A13),
      Color(0xF52B0D0A),
      Color(0xF5170907),
    ],
    GameSurfaceStyle.bronze => const [
      Color(0xEE5A3B20),
      Color(0xF52A1A10),
      Color(0xF5160D08),
    ],
    GameSurfaceStyle.parchment => const [
      Color(0xFFF2DEAA),
      Color(0xFFE0C186),
      Color(0xFFC99E60),
    ],
    GameSurfaceStyle.iron => const [
      Color(0xF5313A3E),
      Color(0xF5182024),
      Color(0xF50C1114),
    ],
  };

  Color get _defaultAccent => switch (style) {
    GameSurfaceStyle.lacquer => const Color(0xFFD69A35),
    GameSurfaceStyle.bronze => const Color(0xFFCC9A4B),
    GameSurfaceStyle.parchment => const Color(0xFF8C572B),
    GameSurfaceStyle.iron => const Color(0xFF78909C),
  };
}

class _GameSurfacePainter extends CustomPainter {
  final Color accent;
  final GameSurfaceStyle style;

  const _GameSurfacePainter({required this.accent, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = accent.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRect(
      Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
      line,
    );
    final corner = Paint()
      ..color = accent.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    const length = 15.0;
    for (final data in [
      (Offset.zero, 1.0, 1.0),
      (Offset(size.width, 0), -1.0, 1.0),
      (Offset(0, size.height), 1.0, -1.0),
      (Offset(size.width, size.height), -1.0, -1.0),
    ]) {
      final origin = data.$1;
      canvas.drawLine(origin, origin + Offset(length * data.$2, 0), corner);
      canvas.drawLine(origin, origin + Offset(0, length * data.$3), corner);
    }
    if (style != GameSurfaceStyle.parchment) {
      canvas.drawLine(
        const Offset(16, 3),
        Offset(size.width - 16, 3),
        Paint()
          ..color = const Color(0x33FFFFFF)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameSurfacePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.style != style;
}
