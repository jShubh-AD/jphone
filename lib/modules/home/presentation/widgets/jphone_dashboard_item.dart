import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';

import 'jphone_edit_controls.dart';
import 'jphone_editor_scope.dart';

/// Wraps an individual dashboard tile in JPhone's visual editing layer.
///
/// Cleanly separates:
/// - Dashboard Engine State (owned by sliver_dashboard)
/// - JPhone Editor UI State (owned by JPhone Homepage / Editor)
/// - Actual Widget Content (owned by the inner cards, strictly preserved)
class JPhoneDashboardItem extends StatelessWidget {
  final Widget child;
  final String itemId;

  /// Whether the dashboard is currently in edit mode.
  /// If null, reactively watches [DashboardController.isEditing].
  final bool? editing;

  /// Whether this item is currently selected in edit mode.
  /// If null, reactively watches [DashboardController.selectedItemIds].
  final bool? selected;

  /// Whether this item is currently undergoing an active resize gesture.
  /// If null, reactively checks [JPhoneEditorScope.resizingItemId].
  final bool? resizing;

  /// Whether this item is currently being dragged.
  /// If null, reactively checks [JPhoneEditorScope.draggingItemId].
  final bool? dragging;

  /// Callback to remove this item from the dashboard layout.
  /// If null, defaults to calling [DashboardController.removeItem].
  final VoidCallback? onRemove;

  const JPhoneDashboardItem({
    super.key,
    required this.child,
    required this.itemId,
    this.editing,
    this.selected,
    this.resizing,
    this.dragging,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<DashboardControllerProvider>()
        ?.controller;

    final editorScope = JPhoneEditorScope.maybeOf(context);

    // Resolve effective states:
    // 1. Prioritize explicit parameters if supplied.
    // 2. Reactively watch controller beacons so that even when sliver_dashboard
    //    caches itemBuilder subtrees, JPhone's editing chrome reacts immediately.
    final bool isEditing;
    if (editing != null) {
      isEditing = editing!;
    } else if (controller != null) {
      isEditing = controller.isEditing.watch(context);
    } else {
      isEditing = false;
    }

    final bool isSelected;
    if (selected != null) {
      isSelected = selected!;
    } else if (controller != null) {
      final selectedIds = controller.selectedItemIds.watch(context);
      isSelected = selectedIds.contains(itemId);
    } else {
      isSelected = false;
    }

    final bool isResizing = resizing ?? (editorScope?.resizingItemId == itemId);
    final bool isDragging = dragging ?? (editorScope?.draggingItemId == itemId);

    final VoidCallback handleRemove = onRemove ??
        () {
          controller?.removeItem(itemId);
        };

    // When in edit mode, provide elevated appearance and subtle lift shadows.
    final List<BoxShadow> shadows;
    if (!isEditing) {
      shadows = const [];
    } else if (isDragging) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 22,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ];
    } else if (isResizing) {
      shadows = [
        BoxShadow(
          color: const Color(0xFF2563EB).withValues(alpha: 0.35),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ];
    } else if (isSelected) {
      shadows = [
        BoxShadow(
          color: const Color(0xFFF97316).withValues(alpha: 0.28),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadows,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. STABLE WIDGET CONTENT
            // Isolated in its own RepaintBoundary so animated borders or
            // controls never trigger rebuilds or repaints of the application widget.
            Positioned.fill(
              child: RepaintBoundary(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              ),
            ),

            // 2. ANIMATED SELECTION BORDER
            // Active only when BOTH editing AND selected are true.
            if (isEditing && isSelected)
              const Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: _AnimatedGradientBorder(radius: 16),
                  ),
                ),
              ),

            // 3. RESIZING ACTIVE HIGHLIGHT
            // Shown when actively resizing this item to provide clear feedback.
            if (isEditing && isResizing)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),

            // 4. JPHONE EDIT CONTROLS (Move handle, Close button, Resize corners)
            // Displayed only while edit mode is ON.
            if (isEditing)
              Positioned.fill(
                child: JPhoneEditControls(
                  itemId: itemId,
                  selected: isSelected,
                  resizing: isResizing,
                  onRemove: handleRemove,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Rotates a continuous SweepGradient border around the widget bounds.
/// Isolated to prevent any repainting of the parent or child content.
class _AnimatedGradientBorder extends StatefulWidget {
  final double radius;
  static const double strokeWidth = 2;

  const _AnimatedGradientBorder({
    required this.radius,
  });

  @override
  State<_AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<_AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _controller.value,
            radius: widget.radius,
            strokeWidth: _AnimatedGradientBorder.strokeWidth,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;

  const _GradientBorderPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = SweepGradient(
      transform: GradientRotation(progress * 2 * math.pi),
      colors: const [
        Color(0xFFEC4899),
        Color(0xFFEC4899),
        Color(0xFFEC4899),
        Color(0xFFFF9DDA),
        Color(0xFF9333EA),
        Color(0xFFFF9DDA),
        Color(0xFFEC4899),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}