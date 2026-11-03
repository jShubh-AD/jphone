import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/widgets/app_text.dart';
import 'dashboard_card_container.dart';
import 'flip_board.dart';

class PomodoroCard extends StatefulWidget {
  final int widthColumns;
  final int heightRows;

  const PomodoroCard({super.key, this.widthColumns = 2, this.heightRows = 2});

  @override
  State<PomodoroCard> createState() => _PomodoroCardState();
}

class _PomodoroCardState extends State<PomodoroCard> {
  Timer? _ticker;

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Design JPhone design system',
      'desc': 'Refine typography, spacing, and micro-interactions.',
      'duration': 25,
      'points': 50,
      'isCompleted': false,
    },
    {
      'id': '2',
      'title': 'Review Financial Pulse metrics',
      'desc': 'Audit weekly subscriptions & daily expenses.',
      'duration': 15,
      'points': 30,
      'isCompleted': false,
    },
    {
      'id': '3',
      'title': 'Draft sprint memo',
      'desc': 'Document widget layout guidelines for production.',
      'duration': 20,
      'points': 40,
      'isCompleted': false,
    },
  ];

  int _currentTaskIndex = 0;
  bool _isRunning = false;
  late int _remainingSeconds;
  bool _isTransitioning = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (_tasks[_currentTaskIndex]['duration'] as int) * 60;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning)
      _stopTimer();
    else
      _startTimer();
  }

  void _startTimer() {
    if (_isRunning) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _handleComplete();
      }
    });
  }

  void _stopTimer() {
    if (!_isRunning) return;
    HapticFeedback.lightImpact();
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _handleComplete() {
    if (_isTransitioning) return;
    HapticFeedback.heavyImpact();

    _stopTimer();

    setState(() {
      _isTransitioning = true;
      _showConfetti = true;
      _tasks[_currentTaskIndex]['isCompleted'] = true;
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        final nextIdx = _tasks.indexWhere((t) => !t['isCompleted']);
        if (nextIdx != -1) {
          _currentTaskIndex = nextIdx;
          _remainingSeconds =
              (_tasks[_currentTaskIndex]['duration'] as int) * 60;
        } else {
          _currentTaskIndex = -1; // All tasks complete
        }
        _isTransitioning = false;
      });
    });
  }

  void _resetTasks() {
    setState(() {
      for (final t in _tasks) {
        t['isCompleted'] = false;
      }
      _currentTaskIndex = 0;
      _remainingSeconds = (_tasks[0]['duration'] as int) * 60;
      _isRunning = false;
      _isTransitioning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool allDone = _currentTaskIndex == -1;
    final isExpanded = widget.widthColumns > 2;

    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: allDone
                  ? _buildAllCompletedView()
                  : (isExpanded
                        ? _buildExpandedContent()
                        : _buildCompactContent()),
            ),

            // Confetti & Reward Overlay (Safely contained without render overflow)
            if (_showConfetti) ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRect(
                    child: Transform.scale(
                      scale: isExpanded ? 1.8 : 1.15,
                      child: Lottie.asset(
                        'assets/animations/confetti_short.lottie',
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Reward pill: Compact shows "+25", Expanded shows full reward
              Positioned(
                top: 8,
                child: IgnorePointer(
                  child:
                      Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isExpanded ? 14 : 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0F172A,
                              ).withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppText('🎉 ', fontSize: 12),
                                AppText(
                                  isExpanded
                                      ? '+${_tasks[(_currentTaskIndex == -1 ? 0 : _currentTaskIndex)]['points']} XP Earned!'
                                      : '+25',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.0, 1.0),
                            curve: Curves.easeOutBack,
                            duration: 250.ms,
                          )
                          .fadeIn(duration: 150.ms),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPACT LAYOUT (2x2 / 2x3)
  // ===========================================================================
  Widget _buildCompactContent() {
    final task = _tasks[_currentTaskIndex];
    final title = task['title'] as String;
    final duration = task['duration'] as int;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          key: ValueKey('compact_${task['id']}_$_isTransitioning'),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: POMODORO badge + Duration Pill with Clock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardBadge(
                  label: 'POMODORO',
                  backgroundColor: _isRunning
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFF7ED),
                  textColor: _isRunning
                      ? const Color(0xFF059669)
                      : const Color(0xFFF97316),
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 10,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 3),
                      AppText(
                        '${duration}m',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Task Title
            Flexible(
              child: AppText(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.2,
              ),
            ),

            // Tapping directly on the Flip Board starts/stops the timer!
            GestureDetector(
              onTap: _toggleTimer,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      FlipClockTimer(
                        totalSeconds: _remainingSeconds,
                        digitWidth: 17,
                        digitHeight: 25,
                        textStyle: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        cardColor: const Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _isRunning
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 11,
                              color: _isRunning
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 2),
                            AppText(
                              _isRunning ? 'STOP' : 'START',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: _isRunning
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 28,
              child: InkWell(
                onTap: _handleComplete,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      AppText(
                        'Complete',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // EXPANDED LAYOUT (3x2 / 4x2 / 4x3) WITH SMOOTH HERO-STYLE TRANSITION
  // ===========================================================================
  Widget _buildExpandedContent() {
    final task = _tasks[_currentTaskIndex];
    final title = task['title'] as String;
    final desc = task['desc'] as String;
    final duration = task['duration'] as int;
    final points = task['points'] as int;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // TOP BAR: Left = Title & Description, Right = Total Time & Points
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top-Left: Task Title & Description underneath
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        if (!_isRunning) ...[
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: AppText(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Top-Right: Total Time & Reward Points
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total Time
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            AppText(
                              '${duration}m',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),

                      // Points to be gained
                      if (widget.widthColumns > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AppText('🏆 ', fontSize: 10),
                              AppText(
                                '+$points XP',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFD97706),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // HERO-STYLE ANIMATED TIMER POSITIONING:
            // When running: Smoothly centers the large timer.
            // When idle: Sits gracefully in lower-left ready for launch.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              left: _isRunning ? 0 : 0,
              right: _isRunning ? 0 : null,
              top: _isRunning
                  ? (constraints.maxHeight * 0.32)
                  : widget.widthColumns > 3
                  ? (constraints.maxHeight * 0.81)
                  : (constraints.maxHeight * 0.56),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                scale: _isRunning ? 1.15 : 0.95,
                alignment: _isRunning ? Alignment.center : Alignment.centerLeft,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: FlipClockTimer(
                      totalSeconds: _remainingSeconds,
                      digitWidth: _isRunning ? 26 : 20,
                      digitHeight: _isRunning ? 38 : 28,
                      cardColor: const Color(0xFF0F172A),
                      colonColor: const Color(0xFF0F172A),
                      textStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: _isRunning ? 22 : 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM ACTION CONTROLS:
            // Re-imagined tactile button controls.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _isRunning
                    // Running Controls: Symmetrical frosted Pause + Complete
                    ? Row(
                        key: const ValueKey('running_controls'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _stopTimer,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pause_circle_outline_rounded,
                                    size: 14,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    'Pause',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF4444),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _handleComplete,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    'Complete',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    // Idle Controls: Start Button on the right + Complete
                    : Row(
                        key: const ValueKey('idle_controls'),
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: _startTimer,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(0xFFFFEDD5),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    size: 15,
                                    color: Color(0xFFF97316),
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    'Start',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF97316),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _handleComplete,
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  AppText(
                                    'Complete',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllCompletedView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          const AppText(
            'All Pomodoro Tasks Complete!',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _resetTasks,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const AppText(
                'Restart Cycle',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
