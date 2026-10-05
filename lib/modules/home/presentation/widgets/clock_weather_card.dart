import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:j_phone/core/const/app_images.dart';
import 'package:j_phone/core/const/theme/app_color.dart';
import 'package:j_phone/core/widgets/app_text.dart';
import 'package:lottie/lottie.dart';

class ClockWeatherCard extends StatelessWidget {
  const ClockWeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final minDimension = width < height ? width : height;

            final bool small = width < 230;
            final bool tiny = width < 190;

            final double horizontalPadding = tiny
                ? 10 : small
                ? 12 : 16;

            final double clockSize = tiny
                ? 34 : small
                ? 40 : 48;

            final double timeFontSize = tiny
                ? 17 : small
                ? 20 : 24;

            final double temperatureFontSize = tiny
                ? 17 : small
                ? 20 : 24;

            final double lottieSize = (minDimension * 0.62).clamp(90.0, 160.0);

            final double glowSize = (minDimension * 0.62).clamp(80.0, 120.0);

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE0F2FE),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: -lottieSize * 0.18,
                  top: -lottieSize * 0.18,
                  child: IgnorePointer(
                    child: Lottie.asset(
                      AppImages.sunnyWeatherGif,
                      width: lottieSize,
                      height: lottieSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Positioned(
                  right: -lottieSize * 0.18,
                  top: -lottieSize * 0.18,
                  child: IgnorePointer(
                    child: Container(
                      width: lottieSize,
                      height: lottieSize,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Color.fromRGBO(255, 255, 255, 0.30),
                            Color.fromRGBO(255, 255, 255, 0.55),
                            Color.fromRGBO(255, 255, 255, 0.0),
                          ],
                          stops: [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: horizontalPadding-1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if(!tiny)
                          Container(
                            width: clockSize,
                            height: clockSize,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F5F9),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              size: 22,
                              color: Color(0xFF64748B),
                            ),
                          ),

                        SizedBox(
                          width: tiny
                              ? 0 : small
                              ? 9 : 14,
                        ),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: AppText(
                                      "09:42",
                                      color: AppColors.neutral,
                                      fontWeight: FontWeight.w700,
                                      fontSize: timeFontSize,
                                      letterSpacing: -0.6,
                                      height: 1.2,
                                    ),
                                  ),

                                  if (!tiny) ...[
                                    const SizedBox(width: 5),
                                    AppText(
                                      "AM",
                                      color: const Color(0xFF64748B),
                                      fontSize: small ? 9 : 11,
                                      letterSpacing: 0.25,
                                    ),
                                  ],
                                ],
                              ),

                              if (!small) ...[
                                const SizedBox(height: 1),
                                AppText(
                                  "Tronica, India",
                                  color: const Color(0xFF64748B),
                                  fontSize: 12,
                                  letterSpacing: 0,
                                  height: 1.4,
                                ),
                              ],
                            ],
                          ),
                        ),

                        if (!tiny) ...[
                          const SizedBox(width: 8),

                          AppText(
                            "32°C",
                            color: AppColors.neutral,
                            fontWeight: FontWeight.w700,
                            fontSize: temperatureFontSize,
                            letterSpacing: 0.1,
                            height: 1.2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
