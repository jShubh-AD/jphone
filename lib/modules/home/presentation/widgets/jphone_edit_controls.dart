import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_phone/core/const/theme/app_color.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';

/// Custom edit controls for a JPhone dashboard item.
///
/// Features:
/// 1. MOVE handle: Uses official [DashboardDragStartListener] to trigger dragging.
/// 2. CLOSE button: Clean [X] button invoking item removal callback.
/// 3. RESIZE indicators: Visual corner brackets highlighting resize affordances.
class JPhoneEditControls extends StatelessWidget {
  final String itemId;
  final bool selected;
  final bool resizing;
  final VoidCallback onRemove;

  const JPhoneEditControls({
    super.key,
    required this.itemId,
    required this.selected,
    required this.resizing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -2,
          top: -2,
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12, width: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.more_vert_outlined,
                size: 18,
                weight: 2,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        Positioned(
          top: -2,
          right: -2,
          child: IgnorePointer(
            child: Container(
              width: 24,
              height: 24,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.1),
                color: const Color(0xFF4E1CE6),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: const [
                    Color(0xFFEC4899),
                    Color(0xFF9333EA),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.open_in_full,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Positioned(
        //   top: -4,
        //   right: -4,
        //   child: GestureDetector(
        //     onTap: () {
        //       HapticFeedback.selectionClick();
        //       onRemove();
        //     },
        //     child: Container(
        //       width: 24,
        //       height: 24,
        //       decoration: BoxDecoration(
        //         color: const Color(0xFFEF4444),
        //         shape: BoxShape.circle,
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withValues(alpha: 0.2),
        //             blurRadius: 4,
        //             offset: const Offset(0, 2),
        //           ),
        //         ],
        //       ),
        //       alignment: Alignment.center,
        //       child: const Icon(
        //         Icons.delete,
        //         size: 13,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ),

        // Corner visual resize indicators
        // Bottom-Right Corner Grip
        // Positioned(
        //   bottom: 0,
        //   right: 0,
        //   child: IgnorePointer(
        //     child: _ResizeCornerIndicator(
        //       corner: _Corner.bottomRight,
        //       active: resizing,
        //     ),
        //   ),
        // ),

        // Bottom-Left Corner Grip
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   child: IgnorePointer(
        //     child: _ResizeCornerIndicator(
        //       corner: _Corner.bottomLeft,
        //       active: resizing,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

//
// enum _Corner { bottomRight, bottomLeft }
//
// class _ResizeCornerIndicator extends StatelessWidget {
//   final _Corner corner;
//   final bool active;
//
//   const _ResizeCornerIndicator({
//     required this.corner,
//     required this.active,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = active ? AppColors.tertiary : AppColors.primary;
//     final size =  11.0;
//
//     return Container(
//       width: size,
//       height: size,
//       color: Colors.transparent,
//       child: CustomPaint(
//         painter: _CornerBracketPainter(
//           corner: corner,
//           color: color,
//           strokeWidth: active ? 2.5 : 1.8,
//         ),
//       ),
//     );
//   }
// }
//
// class _CornerBracketPainter extends CustomPainter {
//   final _Corner corner;
//   final Color color;
//   final double strokeWidth;
//
//   const _CornerBracketPainter({
//     required this.corner,
//     required this.color,
//     required this.strokeWidth,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     const radius = 16.0;
//     const gap = 2.0;
//
//     final path = Path();
//
//     if (corner == _Corner.bottomRight) {
//       path.moveTo(0, size.height + gap);
//
//       path.lineTo(
//         size.width - radius,
//         size.height + gap,
//       );
//
//       path.quadraticBezierTo(
//         size.width + gap,
//         size.height + gap,
//         size.width + gap,
//         size.height - radius,
//       );
//
//       path.lineTo(
//         size.width + gap,
//         0,
//       );
//     } else {
//       path.moveTo(
//         size.width,
//         size.height + gap,
//       );
//
//       path.lineTo(
//         radius,
//         size.height + gap,
//       );
//
//       path.quadraticBezierTo(
//         -gap,
//         size.height + gap,
//         -gap,
//         size.height - radius,
//       );
//
//       path.lineTo(
//         -gap,
//         0,
//       );
//     }
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
//     return oldDelegate.corner != corner ||
//         oldDelegate.color != color ||
//         oldDelegate.strokeWidth != strokeWidth;
//   }
// }
