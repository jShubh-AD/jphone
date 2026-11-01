import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/core/router/app_routes.dart';
import 'package:j_phone/core/widgets/app_elevated_button.dart';
import 'package:sliver_dashboard/sliver_dashboard.dart';
import '../../../../core/const/theme/app_color.dart';
import '../../../../core/widgets/sliver_app_bar.dart';
import '../widgets/clock_weather_card.dart';
import '../widgets/dashboard_styles.dart';
import '../widgets/dummy_wid.dart';
import '../widgets/focus_card.dart';
import '../widgets/jphone_dashboard_item.dart';
import '../widgets/jphone_editor_scope.dart';

/// The JPhone Home dashboard page.
///
/// Implements clear separation of concerns:
/// A. Dashboard Engine State: Owned by [DashboardController] (geometry, collision, reflow, resize math).
/// B. JPhone Editor UI State: Owned here (edit mode, selected item, active resizing item, active dragging item, chrome).
/// C. Actual Widget Content: Stable card widgets ([ClockWeatherCard], [FocusWidget], etc.).
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final DashboardController _dashboardController;
  late final ScrollController _scrollController;

  /// Default layout definition with persistent item IDs.
  static const List<LayoutItem> _defaultLayout = [
    LayoutItem(
      id: 'clock_weather',
      x: 0,
      y: 0,
      w: 4,
      h: 1,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'focus',
      x: 0,
      y: 1,
      w: 2,
      h: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'goal',
      x: 2,
      y: 1,
      w: 2,
      h: 2,
      isDraggable: true,
      isResizable: true,
    ),
    LayoutItem(
      id: 'finance',
      x: 0,
      y: 3,
      w: 4,
      h: 2,
      isDraggable: true,
      isResizable: true,
    ),
  ];

  /// Tracks which item is currently being resized by the user.
  /// Separated completely from selection state.
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
  /// When exiting edit mode, ensures all selection and active interaction states are cleanly purged.
  void _toggleEditMode() {
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

    // If the removed item was selected, remove it from the selection set
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
        content: Text('Removed "$itemId"'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'RESET ALL',
          onPressed: _resetLayout,
        ),
      ),
    );
  }

  /// Restores the default 4-item dashboard layout.
  void _resetLayout() {
    _dashboardController.importLayout(_defaultLayout);
    _dashboardController.clearSelection();
    setState(() {
      _resizingItemId = null;
      _draggingItemId = null;
    });
  }

  /// Builds a dashboard item wrapped in JPhone's visual editing chrome.
  Widget _buildDashboardItem(BuildContext context, LayoutItem item) {
    return JPhoneDashboardItem(
      key: ValueKey(item.id),
      itemId: item.id,
      onRemove: () => _handleRemoveItem(item.id),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_dashboardController.isEditing.value) {
            switch (item.id) {
              case 'clock_weather':
                context.push(AppRoutes.clock);
                break;
              case 'focus':
              case 'goal':
                context.push(AppRoutes.planner);
                break;
              case 'finance':
                context.push(AppRoutes.expenses);
                break;
            }
          }
        },
        child: _buildWidgetContent(item),
      ),
    );
  }

  /// Builds the persistent widget content for each dashboard tile ID.
  Widget _buildWidgetContent(LayoutItem item) {
    switch (item.id) {
      case 'clock_weather':
        return const ClockWeatherCard();

      case 'focus':
        return DummyWidget(title: "Focus");

      case 'goal':
        return const DummyWidget(title: 'Goals');

      case 'finance':
        return const DummyWidget(title: 'Finance');

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                CustomSliverAppBar(
                  title: 'Home',
                  onTap: _toggleEditMode,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  sliver: SliverDashboard(
                    controller: _dashboardController,
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
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AppElevatedButton(
                        text: 'Customize Dashboard',
                        icon: Icons.tune_rounded,
                        borderWidth: 0,
                        borderRadius: 100,
                        shadowColor: const Color(0xFFF97316).withValues(alpha: 0.35),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.buttonGradient,
                            // AppColors.buttonGradient1,
                            AppColors.buttonGradient2,
                            AppColors.buttonGradient3,
                          ],
                        ),
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
