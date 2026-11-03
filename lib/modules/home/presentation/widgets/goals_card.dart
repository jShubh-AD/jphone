import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';
import 'animated_progress_ring.dart';
import 'dashboard_card_container.dart';

class GoalsCard extends StatefulWidget {
  final int widthColumns;

  const GoalsCard({
    super.key,
    this.widthColumns = 2,
  });

  @override
  State<GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends State<GoalsCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.widthColumns > 2;

    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          // Carousel Views
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildTasksView(isExpanded),
                _buildHabitsView(isExpanded),
              ],
            ),
          ),

          // Page indicator dots
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageDot(0),
                const SizedBox(width: 4),
                _buildPageDot(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageDot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 10 : 4,
      height: 3,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTasksView(bool isExpanded) {
    const total = 4;
    const completed = 3;
    const percent = 78;
    const progress = 0.78;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isExpanded) {
          final ringSize = (constraints.maxHeight * 0.75).clamp(50.0, 78.0);
          return Row(
            children: [
              AnimatedProgressRing(
                progress: progress,
                size: ringSize,
                strokeWidth: 6,
                centerChild: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      '$completed/$total',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                    AppText(
                      'DONE',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DashboardBadge(
                          label: 'DAILY GOALS',
                          backgroundColor: Color(0xFFEFF6FF),
                          textColor: Color(0xFF2563EB),
                          fontSize: 10,
                        ),
                        AppText(
                          '$percent%',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const AppText(
                      '3 of 4 tasks completed today',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 2),
                    const AppText(
                      '1 remaining • Swipe for Habits',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Compact 2x2 mode
        final ringSize = (constraints.maxHeight * 0.48).clamp(46.0, 64.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardBadge(
                  label: 'DAILY GOALS',
                  backgroundColor: Color(0xFFEFF6FF),
                  textColor: Color(0xFF2563EB),
                  fontSize: 10,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                ),
                AppText(
                  '$percent%',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ],
            ),

            // Progress Ring
            AnimatedProgressRing(
              progress: progress,
              size: ringSize,
              strokeWidth: 5.5,
              centerChild: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '$completed/$total',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.1,
                  ),
                  AppText(
                    'DONE',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),

            // Subtitle
            const AppText(
              '3 tasks • 4 habits • Daily',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitsView(bool isExpanded) {
    const total = 3;
    const completed = 2;
    const percent = 67;
    const progress = 0.67;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isExpanded) {
          final ringSize = (constraints.maxHeight * 0.75).clamp(50.0, 78.0);
          return Row(
            children: [
              AnimatedProgressRing(
                progress: progress,
                size: ringSize,
                strokeWidth: 6,
                gradientColors: const [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                  Color(0xFFF97316),
                ],
                centerChild: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      '$completed/$total',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.1,
                    ),
                    AppText(
                      'HABITS',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DashboardBadge(
                          label: 'HABIT STREAK',
                          backgroundColor: Color(0xFFFAF5FF),
                          textColor: Color(0xFF9333EA),
                          fontSize: 10,
                        ),
                        AppText(
                          '$percent%',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const AppText(
                      '2 of 3 daily habits logged',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 2),
                    const AppText(
                      'Keep the daily streak alive!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Compact 2x2 mode
        final ringSize = (constraints.maxHeight * 0.48).clamp(46.0, 64.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DashboardBadge(
                  label: 'HABITS',
                  backgroundColor: Color(0xFFFAF5FF),
                  textColor: Color(0xFF9333EA),
                  fontSize: 10,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                ),
                AppText(
                  '$percent%',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ],
            ),

            // Progress Ring
            AnimatedProgressRing(
              progress: progress,
              size: ringSize,
              strokeWidth: 5.5,
              gradientColors: const [
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFFF97316),
              ],
              centerChild: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '$completed/$total',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.1,
                  ),
                  AppText(
                    'LOGGED',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),

            // Subtitle
            const AppText(
              'Daily habit routine • Swipe',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ],
        );
      },
    );
  }
}
