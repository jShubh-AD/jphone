import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';

/// A production-grade 3D Flip Board Digit (like split-flap departure boards & flip clocks).
///
/// Features:
/// - True 3D perspective rotation using [Matrix4] around the X-axis.
/// - Upper and lower half flaps with authentic horizontal crease divider.
/// - Downward 3D flipping animation with realistic lighting gradient shadow during the flip.
class FlipDigit extends StatefulWidget {
  final String digit;
  final TextStyle? textStyle;
  final Color cardColor;
  final Color dividerColor;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const FlipDigit({
    super.key,
    required this.digit,
    this.textStyle,
    this.cardColor = const Color(0xFF0F172A),
    this.dividerColor = const Color(0xFF1E293B),
    this.width = 24.0,
    this.height = 34.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String _currentDigit = '0';
  String _previousDigit = '0';

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _previousDigit = widget.digit;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _previousDigit = _currentDigit;
        });
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _previousDigit = _currentDigit;
      _currentDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get _effectiveStyle =>
      widget.textStyle ??
      const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1.0,
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final bool isFirstHalf = progress <= 0.5;

        // Angle goes from 0 to pi
        final double angle = progress * math.pi;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Static Bottom Flap (shows the new digit)
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildHalfCard(
                  digit: _currentDigit,
                  isUpper: false,
                ),
              ),

              // 2. Static Top Flap (shows the new digit if second half, or old digit if first half)
              Align(
                alignment: Alignment.topCenter,
                child: _buildHalfCard(
                  digit: isFirstHalf ? _previousDigit : _currentDigit,
                  isUpper: true,
                ),
              ),

              // 3. Flipping Flap
              if (_controller.isAnimating)
                Align(
                  alignment: isFirstHalf
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003) // Perspective
                      ..rotateX(isFirstHalf ? -angle : math.pi - angle),
                    alignment: isFirstHalf
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    child: _buildHalfCard(
                      digit: isFirstHalf ? _previousDigit : _currentDigit,
                      isUpper: isFirstHalf,
                      shadowOpacity: isFirstHalf
                          ? (progress * 1.5).clamp(0.0, 0.6)
                          : ((1.0 - progress) * 1.5).clamp(0.0, 0.6),
                    ),
                  ),
                ),

              // 4. Subtle horizontal crease line in the middle
              Center(
                child: Container(
                  height: 1.0,
                  width: widget.width,
                  color: widget.dividerColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHalfCard({
    required String digit,
    required bool isUpper,
    double shadowOpacity = 0.0,
  }) {
    final halfHeight = widget.height / 2;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isUpper ? widget.borderRadius.topLeft : Radius.zero,
        bottom: isUpper ? Radius.zero : widget.borderRadius.bottomLeft,
      ),
      child: Container(
        width: widget.width,
        height: halfHeight,
        color: widget.cardColor,
        child: Stack(
          children: [
            // Number positioned so top half shows top of number, bottom half shows bottom
            Positioned(
              left: 0,
              right: 0,
              top: isUpper ? 0 : -halfHeight,
              height: widget.height,
              child: Center(
                child: AppText(
                  digit,
                  style: _effectiveStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Shading overlay during 3D rotation
            if (shadowOpacity > 0.0)
              Container(
                color: Colors.black.withValues(alpha: shadowOpacity),
              ),
          ],
        ),
      ),
    );
  }
}

/// A complete MM:SS 3D Flip Clock display.
class FlipClockTimer extends StatelessWidget {
  final int totalSeconds;
  final double digitWidth;
  final double digitHeight;
  final TextStyle? textStyle;
  final Color cardColor;
  final Color colonColor;

  const FlipClockTimer({
    super.key,
    required this.totalSeconds,
    this.digitWidth = 22.0,
    this.digitHeight = 32.0,
    this.textStyle,
    this.cardColor = const Color(0xFF0F172A),
    this.colonColor = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (totalSeconds ~/ 60).clamp(0, 99);
    final seconds = (totalSeconds % 60).clamp(0, 59);

    final m1 = (minutes ~/ 10).toString();
    final m2 = (minutes % 10).toString();
    final s1 = (seconds ~/ 10).toString();
    final s2 = (seconds % 10).toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlipDigit(
          digit: m1,
          width: digitWidth,
          height: digitHeight,
          textStyle: textStyle,
          cardColor: cardColor,
        ),
        const SizedBox(width: 3),
        FlipDigit(
          digit: m2,
          width: digitWidth,
          height: digitHeight,
          textStyle: textStyle,
          cardColor: cardColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AppText(
            ':',
            fontSize: digitHeight * 0.6,
            fontWeight: FontWeight.w800,
            color: colonColor,
          ),
        ),
        FlipDigit(
          digit: s1,
          width: digitWidth,
          height: digitHeight,
          textStyle: textStyle,
          cardColor: cardColor,
        ),
        const SizedBox(width: 3),
        FlipDigit(
          digit: s2,
          width: digitWidth,
          height: digitHeight,
          textStyle: textStyle,
          cardColor: cardColor,
        ),
      ],
    );
  }
}

