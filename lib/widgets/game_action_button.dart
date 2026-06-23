import 'package:flutter/material.dart';

enum GameActionStyle { primary, secondary, danger }

class GameActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GameActionStyle style;
  final double? width;
  final double height;

  const GameActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = GameActionStyle.primary,
    this.width,
    this.height = 64,
  });

  @override
  State<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends State<GameActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      child: SizedBox(
        key: ValueKey('game-action-${widget.style.name}'),
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _GameButtonPainter(style: widget.style, enabled: enabled),
          child: ClipPath(
            clipper: const _GameButtonClipper(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onHighlightChanged: enabled
                    ? (value) => setState(() => _pressed = value)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: enabled
                                  ? Colors.white
                                  : const Color(0xFF94857A),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              shadows: const [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameButtonClipper extends CustomClipper<Path> {
  const _GameButtonClipper();

  @override
  Path getClip(Size size) => _buttonPath(size, 13);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GameButtonPainter extends CustomPainter {
  final GameActionStyle style;
  final bool enabled;

  const _GameButtonPainter({required this.style, required this.enabled});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buttonPath(size, 13);
    canvas.drawShadow(path, Colors.black, 8, true);
    final colors = !enabled
        ? const [Color(0xFF403733), Color(0xFF201B19)]
        : switch (style) {
            GameActionStyle.primary => const [
              Color(0xFFE66532),
              Color(0xFF9E2D1D),
              Color(0xFF4A100C),
            ],
            GameActionStyle.secondary => const [
              Color(0xFF2AA9B8),
              Color(0xFF176270),
              Color(0xFF102E38),
            ],
            GameActionStyle.danger => const [
              Color(0xFFC83A2B),
              Color(0xFF71160F),
              Color(0xFF330A08),
            ],
          };
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = enabled ? const Color(0xFFFFD477) : const Color(0xFF756A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final inner = _buttonPath(
      Size(size.width - 10, size.height - 10),
      10,
    ).shift(const Offset(5, 5));
    canvas.drawPath(
      inner,
      Paint()
        ..color = const Color(0x99FFE6A2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawLine(
      Offset(20, 8),
      Offset(size.width - 20, 8),
      Paint()
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _GameButtonPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.enabled != enabled;
}

Path _buttonPath(Size size, double cut) {
  return Path()
    ..moveTo(cut, 0)
    ..lineTo(size.width - cut, 0)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(size.width - cut, size.height)
    ..lineTo(cut, size.height)
    ..lineTo(0, size.height / 2)
    ..close();
}
