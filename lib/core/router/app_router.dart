import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/modules/clock/presentation/pages/clock_page.dart';
import 'package:j_phone/modules/expenses/presentation/pages/expenses_page.dart';
import 'package:j_phone/modules/home/presentation/pages/homepage.dart';
import 'package:j_phone/modules/planner/presentation/pages/create_plan.dart';
import 'package:j_phone/modules/planner/presentation/pages/planner.dart';

import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// The central GoRouter configuration for the JPhone application.
///
/// Designed around an "app-inside-an-app" architecture (like Amazon Pay, Fresh, Pharmacy):
/// Each primary feature tab from the bottom navigation bar is registered as an independent
/// top-level sub-app route with its own internal sub-routes, navigation stack, and logic.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    // -------------------------------------------------------------------------
    // 1. HOME SUB-APP (Root Dashboard)
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (BuildContext context, GoRouterState state) {
        return const Homepage();
      },
    ),

    // -------------------------------------------------------------------------
    // 2. PLANNER SUB-APP
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.planner,
      name: AppRoutes.plannerName,
      builder: (BuildContext context, GoRouterState state) {
        return const Planner();
      },
      routes: [
        GoRoute(
          path: 'create', // Navigates to /planner/create
          name: AppRoutes.plannerCreateName,
          builder: (BuildContext context, GoRouterState state) {
            return const CreatePlan();
          },
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 3. EXPENSES SUB-APP
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.expenses,
      name: AppRoutes.expensesName,
      builder: (BuildContext context, GoRouterState state) {
        return const ExpensesPage();
      },
      routes: const [
        // Additional sub-routes for Expenses (e.g. 'analytics', 'add')
        // can be defined here as this mini-app grows.
      ],
    ),

    // -------------------------------------------------------------------------
    // 4. CLOCK SUB-APP
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.clock,
      name: AppRoutes.clockName,
      builder: (BuildContext context, GoRouterState state) {
        return const ClockPage();
      },
      routes: const [
        // Additional sub-routes for Clock (e.g. 'alarm', 'timer', 'stopwatch')
        // can be defined here as this mini-app grows.
      ],
    ),
  ],

  // ---------------------------------------------------------------------------
  // 404 / UNKNOWN ROUTE FALLBACK
  // ---------------------------------------------------------------------------
  errorBuilder: (BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'No route defined for: ${state.uri}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

/// Type-safe navigation helper methods on [BuildContext] to simplify transitions
/// between the various sub-apps and screens.
extension AppNavigationExtension on BuildContext {
  // --- Replace stack navigation ---
  void goToHome() => go(AppRoutes.home);
  void goToPlanner() => go(AppRoutes.planner);
  void goToExpenses() => go(AppRoutes.expenses);
  void goToClock() => go(AppRoutes.clock);
  void goToCreatePlan() => go(AppRoutes.plannerCreate);

  // --- Push onto current stack navigation ---
  void pushPlanner() => push(AppRoutes.planner);
  void pushExpenses() => push(AppRoutes.expenses);
  void pushClock() => push(AppRoutes.clock);
  void pushCreatePlan() => push(AppRoutes.plannerCreate);
}
