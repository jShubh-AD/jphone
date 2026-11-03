import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:j_phone/core/const/app_assets.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'app_text.dart';

class CelebrationDialog extends StatelessWidget {
  final VideoPlayerController? controller;
  final String title;
  final String? subtitle;

  const CelebrationDialog({
    super.key,
    this.controller,
    required this.title,
    this.subtitle,
  });

  /// Pre-initializes video and presents the celebration dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? videoAssetPath,
  }) async {
    // HapticFeedback.heavyImpact();

    VideoPlayerController? controller;
    if (videoAssetPath != null && videoAssetPath.isNotEmpty) {
      try {
        controller = VideoPlayerController.asset(videoAssetPath);
        await controller.initialize();
        await controller.setLooping(false);
        await controller.setVolume(1.0);
      } catch (e) {
        debugPrint('Celebration video initialization error: $e');
        await controller?.dispose();
        controller = null;
      }
    }

    // 2. Prevent showing if context unmounted during async init
    if (!context.mounted) {
      await controller?.dispose();
      return;
    }

    BuildContext? dialogContext;
    bool isDismissed = false;
    Timer? autoDismissTimer;

    void dismissRoute() {
      if (isDismissed) return;
      isDismissed = true;
      autoDismissTimer?.cancel();

      // Ensure we only dismiss the celebration dialog, never an underlying screen
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }
    }

    // 3. Start playback and set safe auto-dismiss timer based on duration
    if (controller != null && controller.value.isInitialized) {
      controller.play().catchError((error, stackTrace) {
        debugPrint('Celebration video playback error: $error\n$stackTrace');
      });

      final duration = controller.value.duration;
      if (duration > Duration.zero) {
        autoDismissTimer = Timer(
          duration + const Duration(milliseconds: 300),
          dismissRoute,
        );
      }
    }

    // 4. Show dialog with simple fade transition (no heavy scale/zoom transitions)
    try {
      await showGeneralDialog(
        context: context,
        barrierDismissible: true, // Allow tapping outside to dismiss
        barrierLabel: 'Celebration',
        barrierColor: Colors.black.withValues(alpha: 0.75),
        useRootNavigator: true,
        transitionDuration: const Duration(milliseconds: 200),
        transitionBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        pageBuilder: (ctx, anim1, anim2) {
          dialogContext = ctx;
          return CelebrationDialog(
            controller: controller,
            title: title,
            subtitle: subtitle,
          );
        },
      );
    } finally {
      // 5. Cleanup controller and timers cleanly upon dismissal
      isDismissed = true;
      autoDismissTimer?.cancel();

      if (controller != null) {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        await controller.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = controller != null && controller!.value.isInitialized;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  AppAssets.confettiLottie,
                  repeat: false,
                  fit: BoxFit.cover,
                  renderCache: RenderCache.raster,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video Box (rendered directly without offscreen clipping or animations)
                      if (hasVideo) ...[
                        Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.38,
                            maxWidth: 300,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 20,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: controller!.value.aspectRatio,
                              child: VideoPlayer(controller!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // Animated Title
                      AppText(
                            title,
                            textAlign: TextAlign.center,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                            height: 1.2,
                          )
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          ),

                      // Animated Subtitle
                      if (subtitle != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: AppText(
                            subtitle!,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
