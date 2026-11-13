import 'dart:math';
import 'package:flutter/material.dart';

class TouchPoint {
  final int id;
  Offset position;
  final Color color;
  double pulse;

  TouchPoint({
    required this.id,
    required this.position,
    required this.color,
    this.pulse = 0.0,
  });
}

class BurstParticle {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double opacity;

  BurstParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.opacity = 1.0,
  });
}

class TouchCanvasPainter extends CustomPainter {
  final Map<int, TouchPoint> touches;
  final double holdProgress;
  final int? selectedPointerId;
  final List<BurstParticle> particles;
  final double animationValue;

  TouchCanvasPainter({
    required this.touches,
    required this.holdProgress,
    required this.selectedPointerId,
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle ambient cyber grid / background glow
    _drawBackgroundAura(canvas, size);

    // 2. Draw connections between fingers if 2 or more touches exist
    if (touches.length >= 2 && selectedPointerId == null) {
      _drawFingerConnections(canvas);
    }

    // 3. Draw each finger touch circle
    for (final touch in touches.values) {
      final isSelected = selectedPointerId != null && touch.id == selectedPointerId;
      final isOtherDimmed = selectedPointerId != null && touch.id != selectedPointerId;

      _drawTouch(canvas, touch, isSelected, isOtherDimmed);
    }

    // 4. Draw burst particles
    for (final p in particles) {
      final pPaint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(p.position, p.radius, pPaint);
    }
  }

  void _drawBackgroundAura(Canvas canvas, Size size) {
    if (touches.isEmpty) return;

    for (final touch in touches.values) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            touch.color.withOpacity(0.12),
            touch.color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: touch.position, radius: 180));
      canvas.drawCircle(touch.position, 180, glowPaint);
    }
  }

  void _drawFingerConnections(Canvas canvas) {
    final points = touches.values.map((t) => t.position).toList();
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.12 * (1.0 + holdProgress))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        canvas.drawLine(points[i], points[j], linePaint);
      }
    }
  }

  void _drawTouch(Canvas canvas, TouchPoint touch, bool isSelected, bool isDimmed) {
    final pos = touch.position;
    final color = touch.color;
    final double baseOpacity = isDimmed ? 0.15 : 1.0;

    // Outer ripple waves
    final double rippleRadius1 = 55.0 + sin(animationValue * 2 * pi) * 8.0;
    final double rippleRadius2 = 75.0 + cos(animationValue * 2 * pi) * 10.0;

    final ripplePaint = Paint()
      ..color = color.withOpacity(0.25 * baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(pos, rippleRadius1, ripplePaint);
    canvas.drawCircle(pos, rippleRadius2, ripplePaint..color = color.withOpacity(0.15 * baseOpacity));

    // Glow aura
    final auraPaint = Paint()
      ..color = color.withOpacity(0.35 * baseOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 35 : 20);
    canvas.drawCircle(pos, isSelected ? 65 : 45, auraPaint);

    // Inner core circle
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(baseOpacity),
          color.withOpacity(0.9 * baseOpacity),
          color.withOpacity(0.4 * baseOpacity),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: 40));

    canvas.drawCircle(pos, isSelected ? 50 : 38, corePaint);

    // Core border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.9 * baseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, isSelected ? 50 : 38, borderPaint);

    // Hold Timer Progress Arc (when hold is active)
    if (holdProgress > 0 && !isDimmed) {
      final double progressRadius = isSelected ? 58.0 : 48.0;
      final arcPaint = Paint()
        ..color = isSelected ? Colors.white : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final sweepAngle = 2 * pi * holdProgress;
      canvas.drawArc(
        Rect.fromCircle(center: pos, radius: progressRadius),
        -pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TouchCanvasPainter oldDelegate) => true;
}

