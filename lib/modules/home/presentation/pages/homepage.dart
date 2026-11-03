import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/core/router/app_routes.dart';
import 'package:j_phone/core/widgets/app_elevated_button.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/sliver_app_bar.dart';
import '../widgets/activity_streaks_card.dart';
import '../widgets/clock_weather_card.dart';
import '../widgets/dashboard_styles.dart';
import '../widgets/financial_pulse_card.dart';
import '../widgets/pomodoro_card.dart';
import '../widgets/goals_card.dart';
import '../widgets/jphone_dashboard_item.dart';
import '../widgets/jphone_editor_scope.dart';
import '../widgets/quick_links_card.dart';
import '../widgets/quick_memo_card.dart';

/// The JPhone Home dashboard page.
///
/// Implements clear separation of concerns:
/// A. Dashboard Engine State: Owned by [DashboardController] (geometry, collision, reflow, resize math).
/// B. JPhone Editor UI State: Owned here (edit mode, selected item, active resizing item, active dragging item, chrome).
/// C. Actual Widget Content: Production-grade cards ([QuickLinksCard], [ClockWeatherCard], [FocusCard], [GoalsCard], etc.).
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final DashboardController _dashboardController;
  late final ScrollController _scrollController;

  /// Default layout definition matching the reference visual hierarchy with strict min/max constraints.
  static const List<LayoutItem> _defaultLayout = [
    LayoutItem(
      id: 'quick_links',
      x: 0,
      y: 0,
      w: 4,
      h: 1,
      minW: 2,
      maxW: 4,
      minH: 1,
      maxH: 1,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'clock_weather',
      x: 0,
      y: 1,
      w: 4,
      h: 1,
      minW: 1,
      maxW: 4,
      minH: 1,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'pomodoro',
      x: 0,
      y: 2,
      w: 2,
      h: 2,
      minW: 2,
      maxW: 4,
      minH: 2,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'goal',
      x: 2,
      y: 2,
      w: 2,
      h: 2,
      minW: 2,
      maxW: 4,
      minH: 2,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'streaks',
      x: 0,
      y: 4,
      w: 4,
      h: 2,
      minW: 2,
      maxW: 4,
      minH: 2,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'finance',
      x: 0,
      y: 6,
      w: 4,
      h: 2,
      minW: 2,
      maxW: 4,
      minH: 2,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'notes',
      x: 0,
      y: 8,
      w: 4,
      h: 2,
      minW: 2,
      maxW: 4,
      minH: 2,
      maxH: 2,
      isDraggable: true,
      isResizable: true,
    ),
  ];

  /// Tracks which item is currently being resized by the user.
  String? _resizingItemId;

  /// Tracks which item is currently being dragged.
  String? _draggingItemId;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _dashboardController = DashboardController(
      initialSlotCount: 4,
      initialLayout: _defaultLayout,
      onInteractionStart: (_) {
        HapticFeedback.lightImpact();
      },
    );

    // Enable fluid preview during resize (continuous pixel preview before snap)
    _dashboardController.setFluidResize(true);
    _dashboardController.setHandleColor(Colors.transparent);
  }

  @override
  void dispose() {
    _dashboardController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Toggles dashboard edit mode.
  void _toggleEditMode() {
    HapticFeedback.mediumImpact();
    _dashboardController.toggleEditing();

    if (!_dashboardController.isEditing.value) {
      _dashboardController.clearSelection();
      _resizingItemId = null;
      _draggingItemId = null;
    }
    setState(() {});
  }

  /// Removes an item using the official package [DashboardController.removeItem] API.
  void _handleRemoveItem(String itemId) {
    _dashboardController.removeItem(itemId);

    final currentSelection = _dashboardController.selectedItemIds.value;
    if (currentSelection.contains(itemId)) {
      final updated = Set<String>.from(currentSelection)..remove(itemId);
      _dashboardController.selectedItemIds.value = updated;
    }

    if (_resizingItemId == itemId) {
      _resizingItemId = null;
    }
    if (_draggingItemId == itemId) {
      _draggingItemId = null;
    }
    setState(() {});

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('Removed "$itemId"'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(label: 'RESET ALL', onPressed: _resetLayout),
      ),
    );
  }

  /// Restores the default dashboard layout.
  void _resetLayout() {
    _dashboardController.importLayout(_defaultLayout);
    _dashboardController.clearSelection();
    setState(() {
      _resizingItemId = null;
      _draggingItemId = null;
    });
  }

  /// Builds a dashboard item wrapped in JPhone's visual editing chrome with smooth staggered entrance.
  Widget _buildDashboardItem(BuildContext context, LayoutItem item) {
    final index = _defaultLayout.indexWhere((l) => l.id == item.id);
    final delayMs = (index.clamp(0, 6) * 45);

    return JPhoneDashboardItem(
      key: ValueKey(item.id),
      itemId: item.id,
      onRemove: () => _handleRemoveItem(item.id),
      child: _wrapItemTap(item, _buildWidgetContent(item))
          .animate()
          .fadeIn(duration: 350.ms, delay: delayMs.ms)
          .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _wrapItemTap(LayoutItem item, Widget content) {
    // Items like clock_weather need outer tap handling to push route
    if (item.id == 'clock_weather') {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_dashboardController.isEditing.value) {
            context.push(AppRoutes.clock);
          }
        },
        child: content,
      );
    }
    // Other items have their own internal tap targets, gestures, or bottom sheets
    return content;
  }

  /// Builds the persistent widget content for each dashboard tile ID.
  Widget _buildWidgetContent(LayoutItem item) {
    switch (item.id) {
      case 'quick_links':
        return QuickLinksCard(widthColumns: item.w);

      case 'clock_weather':
        return const ClockWeatherCard();

      case 'pomodoro':
      case 'focus':
        return PomodoroCard(widthColumns: item.w, heightRows: item.h);

      case 'goal':
        return GoalsCard(widthColumns: item.w);

      case 'streaks':
        return ActivityStreaksCard(widthColumns: item.w);

      case 'finance':
        return FinancialPulseCard(widthColumns: item.w);

      case 'notes':
        return QuickMemoCard(widthColumns: item.w);

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: JPhoneEditorScope(
          resizingItemId: _resizingItemId,
          draggingItemId: _draggingItemId,
          child: DashboardOverlay(
            controller: _dashboardController,
            scrollController: _scrollController,

            // Track resizing lifecycle independently from selection
            onItemResizeStart: (item) {
              setState(() {
                _resizingItemId = item.id;
              });
            },
            onItemResizeEnd: (item) {
              setState(() {
                _resizingItemId = null;
              });
            },

            // Track drag lifecycle
            onItemDragStart: (item) {
              setState(() {
                _draggingItemId = item.id;
              });
            },
            onItemDragEnd: (item) {
              setState(() {
                _draggingItemId = null;
              });
            },

            // Interaction parameters
            dragStartGesture: DragStartGesture.longPress,
            resizeHandleSide: 24.0,

            // Drag feedback is identical to the child card
            itemFeedbackBuilder: (context, item, child) {
              return child;
            },

            gridStyle: JPhoneDashboardStyles.gridStyle,
            itemStyle: JPhoneDashboardStyles.itemStyle,
            itemBuilder: _buildDashboardItem,

            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                CustomSliverAppBar(title: 'Home', onTap: _toggleEditMode),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  sliver: SliverDashboard(
                    controller: _dashboardController,
                    slotAspectRatio: 0.95,
                    animateReflow: true,
                    reflowDuration: const Duration(milliseconds: 150),
                    fillViewport: true,
                    gridStyle: JPhoneDashboardStyles.gridStyle,
                    itemStyle: JPhoneDashboardStyles.itemStyle,
                    itemBuilder: _buildDashboardItem,
                  ),
                ),

                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AppElevatedButton(
                        text: 'Customize',
                        icon: Icons.tune_rounded,
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
