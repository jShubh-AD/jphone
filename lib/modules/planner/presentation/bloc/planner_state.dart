import 'package:equatable/equatable.dart';
import 'package:j_phone/core/database/app_database.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();

  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {
  const PlannerInitial();
}

class PlannerLoading extends PlannerState {
  const PlannerLoading();
}

class PlannerLoaded extends PlannerState {
  final List<TargetEntity> targets;
  final List<TaskEntity> tasks;
  final String? selectedTargetId;
  final bool isSubmitting;

  const PlannerLoaded({
    required this.targets,
    required this.tasks,
    this.selectedTargetId,
    this.isSubmitting = false,
  });

  List<TaskEntity> get filteredTasks {
    if (selectedTargetId == null) return tasks;
    return tasks.where((t) => t.targetId == selectedTargetId).toList();
  }

  PlannerLoaded copyWith({
    List<TargetEntity>? targets,
    List<TaskEntity>? tasks,
    String? Function()? selectedTargetId,
    bool? isSubmitting,
  }) {
    return PlannerLoaded(
      targets: targets ?? this.targets,
      tasks: tasks ?? this.tasks,
      selectedTargetId: selectedTargetId != null ? selectedTargetId() : this.selectedTargetId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [targets, tasks, selectedTargetId, isSubmitting];
}

class PlannerError extends PlannerState {
  final String message;

  const PlannerError(this.message);

  @override
  List<Object?> get props => [message];
}

