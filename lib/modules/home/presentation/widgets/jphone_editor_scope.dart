import 'package:flutter/widgets.dart';

/// Scoped state for JPhone-specific editing states (resizing item, dragging item).
///
/// Propagates live active-gesture states to dashboard items without forcing
/// entire grid or sliver rebuilds.
class JPhoneEditorScope extends InheritedWidget {
  final String? resizingItemId;
  final String? draggingItemId;

  const JPhoneEditorScope({
    super.key,
    required this.resizingItemId,
    required this.draggingItemId,
    required super.child,
  });

  static JPhoneEditorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JPhoneEditorScope>();
  }

  @override
  bool updateShouldNotify(JPhoneEditorScope oldWidget) {
    return resizingItemId != oldWidget.resizingItemId ||
        draggingItemId != oldWidget.draggingItemId;
  }
}
