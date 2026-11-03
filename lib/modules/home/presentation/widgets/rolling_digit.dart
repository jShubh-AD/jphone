import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';

class RollingDigit extends StatelessWidget {
  final String char;
  final TextStyle style;

  const RollingDigit({
    super.key,
    required this.char,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        final inAnimation = Tween<Offset>(
          begin: const Offset(0.0, -0.6),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return ClipRect(
          child: SlideTransition(
            position: inAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: AppText(
        char,
        key: ValueKey<String>(char),
        style: style,
      ),
    );
  }
}

class RollingTimerDisplay extends StatelessWidget {
  final int totalSeconds;
  final TextStyle style;

  const RollingTimerDisplay({
    super.key,
    required this.totalSeconds,
    this.style = const TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF0F172A),
    ),
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (totalSeconds ~/ 60).clamp(0, 999);
    final seconds = (totalSeconds % 60).clamp(0, 59);

    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < mStr.length; i++)
          RollingDigit(char: mStr[i], style: style),
        AppText(':', style: style),
        for (int i = 0; i < sStr.length; i++)
          RollingDigit(char: sStr[i], style: style),
      ],
    );
  }
}

