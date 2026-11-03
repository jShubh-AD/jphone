import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/app_text.dart';
import 'dashboard_card_container.dart';

class QuickLinksCard extends StatelessWidget {
  final int widthColumns;

  const QuickLinksCard({
    super.key,
    this.widthColumns = 4,
  });

  static const List<Map<String, dynamic>> _shortcuts = [
    {
      'id': '1',
      'name': 'Search',
      'icon': Icons.search_rounded,
      'color': Color(0xFFF97316),
      'bg': Color(0xFFFFF7ED),
    },
    {
      'id': '2',
      'name': 'Chrome',
      'icon': Icons.language_rounded,
      'color': Color(0xFF3B82F6),
      'bg': Color(0xFFEFF6FF),
    },
    {
      'id': '3',
      'name': 'Gemini',
      'icon': Icons.auto_awesome_rounded,
      'color': Colors.white,
      'isGemini': true,
    },
    {
      'id': '4',
      'name': 'YouTube',
      'icon': Icons.play_circle_filled_rounded,
      'color': Color(0xFFEF4444),
      'bg': Color(0xFFFEF2F2),
    },
    {
      'id': '5',
      'name': 'Camera',
      'icon': Icons.camera_alt_rounded,
      'color': Color(0xFFEC4899),
      'bg': Color(0xFFFDF2F8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = widthColumns <= 2 ? 3 : _shortcuts.length;
          final visible = _shortcuts.take(count).toList();
          final iconBoxSize =
              (constraints.maxHeight * 0.58).clamp(36.0, 48.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: visible.map((item) {
              final isGemini = item['isGemini'] == true;
              final Color color = item['color'] as Color;

              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AppText('Opening ${item['name']}...'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          gradient: isGemini
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFFEC4899)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isGemini ? null : (item['bg'] as Color?),
                          borderRadius:
                              BorderRadius.circular(iconBoxSize * 0.32),
                          border: Border.all(
                            color: isGemini
                                ? Colors.transparent
                                : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isGemini
                                      ? const Color(0xFF8B5CF6)
                                      : color)
                                  .withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            item['icon'] as IconData,
                            size: iconBoxSize * 0.52,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AppText(
                          item['name'] as String,
                          maxLines: 1,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
