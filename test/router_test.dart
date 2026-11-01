import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/core/router/app_router.dart';
import 'package:j_phone/core/router/app_routes.dart';
import 'package:j_phone/modules/clock/presentation/pages/clock_page.dart';
import 'package:j_phone/modules/expenses/presentation/pages/expenses_page.dart';
import 'package:j_phone/modules/planner/presentation/pages/create_plan.dart';
import 'package:j_phone/modules/planner/presentation/pages/planner.dart';

void main() {
  group('GoRouter Configuration Tests', () {
    test('Router defines all bottom navigation tabs and sub-app routes', () {
      final routes = appRouter.configuration.routes;
      final topPaths = routes.whereType<GoRoute>().map((r) => r.path).toList();

      expect(topPaths, contains(AppRoutes.home));
      expect(topPaths, contains(AppRoutes.planner));
      expect(topPaths, contains(AppRoutes.expenses));
      expect(topPaths, contains(AppRoutes.clock));
    });

    test('Planner sub-app defines create plan sub-route', () {
      final plannerRoute = appRouter.configuration.routes
          .whereType<GoRoute>()
          .firstWhere((r) => r.path == AppRoutes.planner);

      final childPaths = plannerRoute.routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(childPaths, contains('create'));
    });

    testWidgets('Sub-app screens render correctly', (tester) async {
      // 1. Planner Screen
      await tester.pumpWidget(
        const MaterialApp(home: Planner()),
      );
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);

      // 2. Create Plan Screen
      await tester.pumpWidget(
        const MaterialApp(home: CreatePlan()),
      );
      expect(find.text('Create Plan'), findsOneWidget);

      // 3. Expenses Screen
      await tester.pumpWidget(
        const MaterialApp(home: ExpensesPage()),
      );
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Expenses App'), findsOneWidget);

      // 4. Clock Screen
      await tester.pumpWidget(
        const MaterialApp(home: ClockPage()),
      );
      expect(find.text('Clock'), findsOneWidget);
      expect(find.text('Clock App'), findsOneWidget);
    });
  });
}
