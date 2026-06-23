import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: SizedBox(
        height: 46,
        child: CustomPaint(
          painter: const _SectionBannerPainter(),
          child: Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE3A0),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
              SizedBox(width: 30, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionBannerPainter extends CustomPainter {
  const _SectionBannerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cut = 18.0;
    final path = Path()
      ..moveTo(cut, 3)
      ..lineTo(size.width - cut, 3)
      ..lineTo(size.width - 4, size.height / 2)
      ..lineTo(size.width - cut, size.height - 3)
      ..lineTo(cut, size.height - 3)
      ..lineTo(4, size.height / 2)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6E2519), Color(0xFF32100C), Color(0xFF180806)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD8A044)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      Offset(cut + 10, 8),
      Offset(size.width - cut - 10, 8),
      Paint()
        ..color = const Color(0x66FFE4A0)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
