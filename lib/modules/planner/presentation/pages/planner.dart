import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/core/const/theme/app_color.dart';
import 'package:j_phone/core/router/app_routes.dart';
import 'package:j_phone/core/widgets/app_elevated_button.dart';
import 'package:j_phone/core/widgets/app_text.dart';
import 'package:j_phone/core/widgets/sliver_app_bar.dart';
import 'package:j_phone/modules/planner/domain/planner_enums.dart';
import 'package:j_phone/modules/planner/presentation/bloc/planner_bloc.dart';

class Planner extends StatelessWidget {
  const Planner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<PlannerBloc, PlannerState>(
              builder: (context, state) {
                if (state is PlannerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is PlannerError) {
                  return Center(
                    child: AppText(
                      state.message,
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  );
                }

                final loadedState = state is PlannerLoaded
                    ? state
                    : const PlannerLoaded(targets: [], tasks: []);

                final targets = loadedState.targets;
                final tasks = loadedState.filteredTasks;

                return CustomScrollView(
                  slivers: [
                    const CustomSliverAppBar(title: 'Planner', showBack: true),

                    // Targets Filter Row
                    if (targets.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: targets.length + 1,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  final isSelected = loadedState.selectedTargetId == null;
                                  return FilterChip(
                                    label: AppText('All (${loadedState.tasks.length})'),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      context
                                          .read<PlannerBloc>()
                                          .add(const PlannerTargetSelected(null));
                                    },
                                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                    checkmarkColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected ? AppColors.primary : AppColors.neutral,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }

                                final target = targets[index - 1];
                                final isSelected = loadedState.selectedTargetId == target.id;
                                final targetTaskCount = loadedState.tasks
                                    .where((t) => t.targetId == target.id)
                                    .length;

                                return FilterChip(
                                  label: AppText('${target.name} ($targetTaskCount)'),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    context.read<PlannerBloc>().add(
                                          PlannerTargetSelected(
                                            isSelected ? null : target.id,
                                          ),
                                        );
                                  },
                                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.primary : AppColors.neutral,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Empty State or Task List
                    if (tasks.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 64,
                                color: AppColors.neutral.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              const AppText(
                                'No tasks here yet',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                'Tap "+ Add Plan" below to set up your tasks',
                                fontSize: 14,
                                color: AppColors.neutral.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        sliver: SliverList.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final isDone = task.status == TaskStatus.completed;

                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                context.read<PlannerBloc>().add(PlannerTaskDeleted(task.id));
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                color: Colors.white.withValues(alpha: 0.9),
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(
                                      isDone
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: isDone
                                          ? Colors.green
                                          : AppColors.neutral.withValues(alpha: 0.4),
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      context.read<PlannerBloc>().add(PlannerTaskToggled(task));
                                    },
                                  ),
                                  title: AppText(
                                    task.title,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone
                                        ? AppColors.neutral.withValues(alpha: 0.4)
                                        : AppColors.neutral,
                                  ),
                                  subtitle: task.description != null && task.description!.isNotEmpty
                                      ? AppText(
                                          task.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          color: AppColors.neutral.withValues(alpha: 0.6),
                                        )
                                      : null,
                                  trailing: _buildPriorityChip(task.priority),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),

            // Floating Add Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppElevatedButton(
                  text: 'Add Plan',
                  icon: Icons.add,
                  iconSize: 22,
                  borderWidth: 0,
                  borderRadius: 100,
                  shadowColor: const Color(0xFFF97316).withValues(alpha: 0.35),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.buttonGradient,
                      AppColors.buttonGradient2,
                      AppColors.buttonGradient3,
                    ],
                  ),
                  onPressed: () {
                    context.push(AppRoutes.plannerCreate);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.redAccent;
        label = 'High';
        break;
      case TaskPriority.medium:
        color = Colors.orangeAccent;
        label = 'Med';
        break;
      case TaskPriority.low:
        color = Colors.blueAccent;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        label,
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
