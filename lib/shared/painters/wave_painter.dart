import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveHeaderPainter extends CustomPainter {
  final Color color;
  final Color? secondaryColor;

  WaveHeaderPainter({required this.color, this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (secondaryColor != null) {
      final bgPaint = Paint()..color = secondaryColor!;
      final bgPath = Path()
        ..lineTo(0, h * 0.75)
        ..cubicTo(w * 0.3, h * 0.95, w * 0.65, h * 0.65, w, h * 0.8)
        ..lineTo(w, 0)
        ..close();
      canvas.drawPath(bgPath, bgPaint);
    }

    final paint = Paint()..color = color;
    final path = Path()
      ..lineTo(0, h * 0.65)
      ..cubicTo(w * 0.25, h * 0.85, w * 0.55, h * 0.55, w * 0.75, h * 0.7)
      ..cubicTo(w * 0.88, h * 0.78, w * 0.95, h * 0.6, w, h * 0.65)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveHeaderPainter old) =>
      color != old.color || secondaryColor != old.secondaryColor;
}

class TopographyPainter extends CustomPainter {
  final Color lineColor;

  TopographyPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final w = size.width;
    final h = size.height;
    final rng = math.Random(42);

    for (var i = 0; i < 8; i++) {
      final cx = w * (0.2 + rng.nextDouble() * 0.6);
      final cy = h * (0.2 + rng.nextDouble() * 0.5);
      for (var r = 1; r <= 3 + rng.nextInt(3); r++) {
        final radius = 20.0 + r * 18.0;
        final path = Path();
        final points = 60;
        for (var p = 0; p <= points; p++) {
          final angle = (p / points) * 2 * math.pi;
          final wobble = 1.0 + 0.12 * math.sin(angle * 3 + r);
          final x = cx + radius * wobble * math.cos(angle);
          final y = cy + radius * wobble * 0.7 * math.sin(angle);
          if (p == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TopographyPainter old) =>
      lineColor != old.lineColor;
}

class WaveHeaderWidget extends StatelessWidget {
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color? topographyColor;
  final Widget? child;

  const WaveHeaderWidget({
    super.key,
    this.height = 280,
    required this.primaryColor,
    required this.secondaryColor,
    this.topographyColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WaveHeaderPainter(
                color: primaryColor,
                secondaryColor: secondaryColor,
              ),
            ),
          ),
          if (topographyColor != null)
            Positioned.fill(
              child: CustomPaint(
                painter: TopographyPainter(lineColor: topographyColor!),
              ),
            ),
          if (child != null)
            Positioned.fill(child: child!),
        ],
      ),
    );
  }
}
