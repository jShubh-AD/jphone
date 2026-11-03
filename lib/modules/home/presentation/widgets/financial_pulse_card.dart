import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/app_text.dart';
import 'dashboard_card_container.dart';

class FinancialPulseCard extends StatelessWidget {
  final int widthColumns;

  const FinancialPulseCard({
    super.key,
    this.widthColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = widthColumns <= 2 || constraints.maxWidth < 180;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const DashboardCardHeader(
                title: 'Financial Pulse',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: Color(0xFFF97316),
                badge: DashboardBadge(
                  label: 'On Target',
                  backgroundColor: Color(0xFFECFDF5),
                  textColor: Color(0xFF059669),
                  fontSize: 10,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                ),
              ),
              const SizedBox(height: 6),

              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'Available Funds',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppText(
                            r'$4,280.50',
                            fontSize: isCompact ? 16 : 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const AppText(
                          'Spent Today',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppText(
                            r'-$142.00',
                            fontSize: isCompact ? 12 : 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Sparkline Chart
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SparklinePainter(),
                    )
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 100.ms)
                    .scaleX(begin: 0.94, end: 1.0, curve: Curves.easeOutCubic),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;

    final points = [
      Offset(0, h * 0.85),
      Offset(w * 0.20, h * 0.70),
      Offset(w * 0.40, h * 0.65),
      Offset(w * 0.60, h * 0.50),
      Offset(w * 0.75, h * 0.55),
      Offset(w * 0.88, h * 0.40),
      Offset(w, h * 0.45),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.25),
          const Color(0xFFF97316).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    final todayPoint = points[3];
    final dotPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(todayPoint, 3.5, dotPaint);
    canvas.drawCircle(todayPoint, 3.5, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
