import 'package:flutter/material.dart';
import '../../../../core/const/theme/app_color.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/sliver_app_bar.dart';

/// The Clock sub-app screen.
///
/// Serves as the independent "Clock mini-app" entry point (alarms, world clock, timer, stopwatch).
class ClockPage extends StatelessWidget {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(
              title: 'Clock',
              showBack: true,
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        size: 38,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AppText(
                      'Clock App',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral,
                    ),
                    const SizedBox(height: 8),
                    const AppText(
                      'Alarms, world clock, timers, and stopwatches in this standalone sub-app.',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.navbarTextClr,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
