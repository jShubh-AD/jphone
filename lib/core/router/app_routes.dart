/// Defines all route names and paths used across the JPhone application.
///
/// Designed to support an "app-inside-an-app" architecture (similar to Amazon
/// with Amazon Pay, Pharmacy, Marketplace, etc.). Each feature module acts as
/// its own self-contained sub-app with its own screen stack and route hierarchy.
abstract class AppRoutes {
  // ---------------------------------------------------------------------------
  // Home Sub-App (Root)
  // ---------------------------------------------------------------------------
  static const String home = '/';
  static const String homeName = 'home';

  // ---------------------------------------------------------------------------
  // Planner Sub-App
  // ---------------------------------------------------------------------------
  static const String planner = '/planner';
  static const String plannerName = 'planner';

  static const String plannerCreate = '/planner/create';
  static const String plannerCreateName = 'planner_create';

  // ---------------------------------------------------------------------------
  // Expenses Sub-App
  // ---------------------------------------------------------------------------
  static const String expenses = '/expenses';
  static const String expensesName = 'expenses';

  // ---------------------------------------------------------------------------
  // Clock Sub-App
  // ---------------------------------------------------------------------------
  static const String clock = '/clock';
  static const String clockName = 'clock';
}
