import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_phone/main.dart';
import 'package:j_phone/modules/home/presentation/widgets/clock_weather_card.dart';
import 'package:j_phone/modules/home/presentation/widgets/jphone_dashboard_item.dart';
import 'package:j_phone/modules/home/presentation/widgets/jphone_edit_controls.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';

void main() {
  testWidgets('TEST A: Normal Mode - Widgets render without edit chrome', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify all 4 initial dashboard widgets render
    expect(find.byType(ClockWeatherCard), findsOneWidget);
    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);

    // Verify no edit controls exist
    expect(find.byType(JPhoneEditControls), findsNothing);
    expect(find.text('MOVE'), findsNothing);
  });

  testWidgets('TEST B: Enter Edit Mode - Elevated widgets and custom controls appear', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Enter edit mode by tapping the edit icon in CustomAppBar
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // 2. Verify JPhone custom edit controls appeared on each item
    expect(find.byType(JPhoneEditControls), findsNWidgets(4));
    expect(find.text('MOVE'), findsNWidgets(4));
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(4));
    expect(find.byType(DashboardDragStartListener), findsNWidgets(4));
  });

  testWidgets('TEST C: Select & Deselect - Animated gradient border appears only on selected item', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // Tap on Focus tile to select it
    await tester.tap(find.text('Deep Work'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Focus edit controls has selected == true
    final focusControls = tester.widget<JPhoneEditControls>(
      find.descendant(
        of: find.ancestor(of: find.text('Deep Work'), matching: find.byType(JPhoneDashboardItem)),
        matching: find.byType(JPhoneEditControls),
      ),
    );
    expect(focusControls.selected, isTrue);

    // Verify other tiles have selected == false
    final goalControls = tester.widget<JPhoneEditControls>(
      find.descendant(
        of: find.ancestor(of: find.text('Goals'), matching: find.byType(JPhoneDashboardItem)),
        matching: find.byType(JPhoneEditControls),
      ),
    );
    expect(goalControls.selected, isFalse);

    // Deselect Focus by tapping it again
    await tester.tap(find.text('Deep Work'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final deselectedFocusControls = tester.widget<JPhoneEditControls>(
      find.descendant(
        of: find.ancestor(of: find.text('Deep Work'), matching: find.byType(JPhoneDashboardItem)),
        matching: find.byType(JPhoneEditControls),
      ),
    );
    expect(deselectedFocusControls.selected, isFalse);
  });

  testWidgets('TEST D: Drag Focus using Move Handle - initiates dragging and reflows layout', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // Find the move handle for Focus tile
    final focusItemFinder = find.ancestor(
      of: find.text('Deep Work'),
      matching: find.byType(JPhoneDashboardItem),
    );
    final moveHandleFinder = find.descendant(
      of: focusItemFinder,
      matching: find.byType(DashboardDragStartListener),
    );
    expect(moveHandleFinder, findsOneWidget);

    // Drag Focus down using the custom move handle
    await tester.timedDrag(moveHandleFinder, const Offset(0, 250), const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Focus card identity and content are preserved
    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.byType(ClockWeatherCard), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
  });

  testWidgets('TEST E: Resize controls are present and configured', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // Verify overlay is configured with resize handle side of 24.0 and fluid resize
    final overlay = tester.widget<DashboardOverlay>(find.byType(DashboardOverlay));
    expect(overlay.resizeHandleSide, 24.0);
    expect(overlay.controller.fluidResize.value, isTrue);
  });

  testWidgets('TEST F: Exit Edit Mode - Complete cleanup with zero stale state', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Enter edit mode
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // 2. Select an item (repeating border animation begins)
    await tester.tap(find.text('Deep Work'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 3. Exit edit mode by tapping edit button again (stopping border animation)
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // 4. Verify ALL edit controls are gone
    expect(find.byType(JPhoneEditControls), findsNothing);
    expect(find.text('MOVE'), findsNothing);

    // 5. Re-enter edit mode and verify clean state (no item selected)
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    final allControls = tester.widgetList<JPhoneEditControls>(find.byType(JPhoneEditControls));
    expect(allControls.length, 4);
    for (final control in allControls) {
      expect(control.selected, isFalse);
      expect(control.resizing, isFalse);
    }
  });

  testWidgets('TEST G: Repeated Transitions - No stale state after multiple toggles', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    for (int i = 0; i < 4; i++) {
      // Enter edit
      await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
      await tester.pumpAndSettle();

      // Select Focus
      await tester.tap(find.text('Deep Work'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Exit edit
      await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
      await tester.pumpAndSettle();

      // Verify clean
      expect(find.byType(JPhoneEditControls), findsNothing);
    }
  });

  testWidgets('TEST H: Remove Item - Close button removes item via official API', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter edit mode
    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    // Verify 4 items initially
    expect(find.text('Goals'), findsOneWidget);

    // Find the close button for the Goals tile
    final goalItemFinder = find.ancestor(
      of: find.text('Goals'),
      matching: find.byType(JPhoneDashboardItem),
    );
    final closeButtonFinder = find.descendant(
      of: goalItemFinder,
      matching: find.byIcon(Icons.close_rounded),
    );

    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // Verify Goals is removed from the dashboard layout
    expect(find.text('Goals'), findsNothing);
    expect(find.text('Removed "goal"'), findsOneWidget);

    // Verify remaining 3 items still exist
    expect(find.byType(ClockWeatherCard), findsOneWidget);
    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
  });
}
