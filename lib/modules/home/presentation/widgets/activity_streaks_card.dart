import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/const/app_assets.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/celebration_dialog.dart';
import 'dashboard_card_container.dart';

class ActivityStreaksCard extends StatefulWidget {
  final int widthColumns;

  const ActivityStreaksCard({super.key, this.widthColumns = 4});

  @override
  State<ActivityStreaksCard> createState() => _ActivityStreaksCardState();
}

class _ActivityStreaksCardState extends State<ActivityStreaksCard> {
  // In-memory dummy habits for smooth, crash-free execution
  final List<Map<String, dynamic>> _habits = [
    {
      'id': 'hydration',
      'title': 'Hydration',
      'current': 5.0,
      'target': 8.0,
      'unit': 'gl',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF0EA5E9),
      'streak': 7,
    },
    {
      'id': 'mindfulness',
      'title': 'Mindfulness',
      'current': 1.0,
      'target': 1.0,
      'unit': '',
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFFEC4899),
      'streak': 12,
    },
    {
      'id': 'knowledge',
      'title': 'Knowledge',
      'current': 20.0,
      'target': 30.0,
      'unit': 'min',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFF97316),
      'streak': 5,
    },
  ];

  void _increment(int index) {
    final h = _habits[index];
    final String unit = h['unit'] as String;
    final double target = h['target'] as double;

    HapticFeedback.heavyImpact();
    double updatedCurrent = 0;

    setState(() {
      double current = h['current'] as double;
      final delta = unit == 'min' ? 5.0 : 1.0;
      current += delta;
      if (current > target * 1.5) {
        current = 0.0; // reset loop
      }
      h['current'] = current;
      updatedCurrent = current;
    });

    // Trigger full-screen locked celebration on each water glass increment
    if (unit == 'gl') {
      CelebrationDialog.show(
        context,
        title: 'Great work drinking water!!!',
        subtitle:
            '${updatedCurrent.toInt()} of ${target.toInt()} glasses logged',
        videoAssetPath: AppAssets.drinkingWaterVideo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const DashboardCardHeader(
            title: 'Active Streaks',
            icon: Icons.local_fire_department_rounded,
            iconColor: Color(0xFFEF4444),
            badge: DashboardBadge(
              label: '12 Days Master',
              backgroundColor: Color(0xFFFEF2F2),
              textColor: Color(0xFFE11D48),
              fontSize: 10,
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            ),
          ),
          const SizedBox(height: 8),

          // 3 Habit Cards Row
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < _habits.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? 0 : 3.0,
                        right: i == _habits.length - 1 ? 0 : 3.0,
                      ),
                      child: _buildHabitCard(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(int index) {
    final habit = _habits[index];
    final double current = habit['current'] as double;
    final double target = habit['target'] as double;
    final String unit = habit['unit'] as String;
    final IconData icon = habit['icon'] as IconData;
    final Color color = habit['color'] as Color;
    final int streak = habit['streak'] as int;

    String displayValue;
    if (unit == 'gl') {
      displayValue = '${current.toInt()} / ${target.toInt()} gl';
    } else if (unit == 'min') {
      displayValue = '${current.toInt()} min';
    } else {
      displayValue = '$streak-Day 🔥';
    }

    final double progress = target > 0
        ? (current / target).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _increment(index),
            borderRadius: BorderRadius.circular(14),
            child:
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: (constraints.maxHeight * 0.28).clamp(
                              16.0,
                              22.0,
                            ),
                            color: color,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppText(
                              displayValue,
                              maxLines: 1,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          AppText(
                            habit['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              height: 3.5,
                              width: double.infinity,
                              color: const Color(0xFFE2E8F0),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(key: ValueKey('punch_${index}_$current'))
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1.0, 1.0),
                      duration: 200.ms,
                      curve: Curves.easeOutBack,
                    ),
          ),
        );
      },
    );
  }
}
