import 'package:equatable/equatable.dart';
import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/domain/planner_enums.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to start watching database streams
class PlannerStarted extends PlannerEvent {
  const PlannerStarted();
}

/// Dispatched when the targets stream emits new data
class PlannerTargetsUpdated extends PlannerEvent {
  final List<TargetEntity> targets;

  const PlannerTargetsUpdated(this.targets);

  @override
  List<Object?> get props => [targets];
}

/// Dispatched when the tasks stream emits new data
class PlannerTasksUpdated extends PlannerEvent {
  final List<TaskEntity> tasks;

  const PlannerTasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

/// Filter tasks by a target (or pass null to show all)
class PlannerTargetSelected extends PlannerEvent {
  final String? targetId;

  const PlannerTargetSelected(this.targetId);

  @override
  List<Object?> get props => [targetId];
}

/// Toggle task completion status
class PlannerTaskToggled extends PlannerEvent {
  final TaskEntity task;

  const PlannerTaskToggled(this.task);

  @override
  List<Object?> get props => [task];
}

/// Create a new Target
class PlannerTargetCreated extends PlannerEvent {
  final String name;
  final String? description;
  final int? color;
  final String? icon;
  final DateTime? deadline;

  const PlannerTargetCreated({
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.deadline,
  });

  @override
  List<Object?> get props => [name, description, color, icon, deadline];
}

/// Create a new Task
class PlannerTaskCreated extends PlannerEvent {
  final String title;
  final String? description;
  final String? targetId;
  final String? trackId;
  final TaskPriority priority;
  final bool isImportant;
  final DateTime? dueDate;

  const PlannerTaskCreated({
    required this.title,
    this.description,
    this.targetId,
    this.trackId,
    this.priority = TaskPriority.medium,
    this.isImportant = false,
    this.dueDate,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        targetId,
        trackId,
        priority,
        isImportant,
        dueDate,
      ];
}

/// Delete a Task by ID
class PlannerTaskDeleted extends PlannerEvent {
  final String id;

  const PlannerTaskDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Delete a Target by ID
class PlannerTargetDeleted extends PlannerEvent {
  final String id;

  const PlannerTargetDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
