import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Rock-solid dual-gradient circular progress ring.
///
/// Guaranteed zero-clipping architecture:
/// - Explicit geometric radius with safety inset: `(size - strokeWidth)/2 - 3.0`.
/// - Direct canvas drawing with [SweepGradient] shader (no [ShaderMask] boundary clipping).
/// - [StrokeCap.round] for smooth rounded pill ends.
/// - Declarative [TweenAnimationBuilder] for 60FPS fluid transitions.
class AnimatedProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double strokeWidth;
  final Widget? centerChild;
  final double size;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 6.0,
    this.centerChild,
    this.size = 70.0,
    this.gradientColors = const [
      Color(0xFFF97316), // Sunset Orange
      Color(0xFFEC4899), // Pink
      Color(0xFF6366F1), // Violet
    ],
    this.backgroundColor = const Color(0xFFF1F5F9),
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: clampedProgress),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: animatedValue,
              strokeWidth: strokeWidth,
              gradientColors: gradientColors,
              backgroundColor: backgroundColor,
            ),
            child: centerChild != null ? Center(child: centerChild) : null,
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Inset by half-stroke plus an explicit 3.0px safety margin to ensure zero edge cutting
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2 - 3.0;

    if (radius <= 0) return;

    final circleRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Background Track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Gradient Progress Arc
    if (progress > 0.0) {
      const startAngle = -math.pi / 2; // 12 o'clock
      final sweepAngle = 2 * math.pi * progress;

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0.0,
          endAngle: 2 * math.pi,
          colors: gradientColors,
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(circleRect);

      canvas.drawArc(circleRect, startAngle, sweepAngle, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
