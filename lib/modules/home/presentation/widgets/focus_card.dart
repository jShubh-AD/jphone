import 'package:flutter/material.dart';

import 'package:j_phone/core/const/enums/app_enums.dart';
import 'package:j_phone/core/const/theme/app_color.dart';
import 'package:j_phone/core/widgets/app_text.dart';

class FocusWidget extends StatelessWidget {
  final FocusState state;

  final String? title;
  final String? subtitle;
  final String? time;
  final int? duration;

  final VoidCallback? onAddTask;
  final VoidCallback? onComplete;
  final VoidCallback? onNextFocus;

  // Replace this with your Lottie/Rive/custom animation.
  final Widget? completionAnimation;

  const FocusWidget({
    super.key,
    required this.state,
    this.title,
    this.subtitle,
    this.time,
    this.duration,
    this.onAddTask,
    this.onComplete,
    this.onNextFocus,
    this.completionAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: _buildState(),
    );
  }

  Widget _buildState() {
    switch (state) {
      case FocusState.empty:
        return _buildEmpty();

      case FocusState.active:
        return _buildActive();

      case FocusState.completed:
        return _buildCompleted();
    }
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmpty() {
    return _FocusCard(
      key: const ValueKey('empty'),
      child: InkWell(
        onTap: onAddTask,
        borderRadius: BorderRadius.circular(22),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF64748B),
                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              AppText(
                'ADD FOCUS',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),

              const SizedBox(height: 6),

              AppText(
                'Add a task',
                color: AppColors.neutral,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),

              const SizedBox(height: 4),

              AppText(
                'Choose what you want to focus on next',
                color: const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIVE STATE
  // ===========================================================================

  Widget _buildActive() {
    return _FocusCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppText(
                    'NEXT FOCUS',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                if (duration != null)
                  _DurationBadge(
                    duration: duration!,
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Task title
            AppText(
              title ?? 'Untitled task',
              color: AppColors.neutral,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),

            if (subtitle != null)
              AppText(
                subtitle!,
                color: AppColors.neutral,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),

            const SizedBox(height: 5),

            // Time
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 26,
                  color: Color(0xFF64748B),
                ),

                const SizedBox(width: 5),

                AppText(
                  time ?? '10:00 AM',
                  color: const Color(0xFF64748B),
                  fontSize: 16,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Complete button
            GestureDetector(
              onTap: onComplete,
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF64748B),
                          width: 2,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    AppText(
                      'Complete',
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  // ===========================================================================
  // COMPLETED STATE
  // ===========================================================================

  Widget _buildCompleted() {
    return _FocusCard(
      key: const ValueKey('completed'),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: completionAnimation ??
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 56,
                    color: Color(0xFF22C55E),
                  ),
            ),

            const SizedBox(height: 8),

            AppText(
              'Focus Complete',
              color: AppColors.neutral,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),

            const SizedBox(height: 4),

            AppText(
              'Nice work.',
              color: const Color(0xFF64748B),
              fontSize: 13,
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: onNextFocus,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: AppText(
                  'Next Focus',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CARD
// =============================================================================

class _FocusCard extends StatelessWidget {
  final Widget child;

  const _FocusCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 246,
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// =============================================================================
// DURATION BADGE
// =============================================================================

class _DurationBadge extends StatelessWidget {
  final int duration;

  const _DurationBadge({
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: AppText(
        '${duration}m',
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}