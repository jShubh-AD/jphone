import 'package:j_phone/core/database/app_database.dart';
import 'planner_repository.dart';

/// Single unified UseCase class for all Planner business operations.
class PlannerUseCases {
  final PlannerRepository _repository;

  const PlannerUseCases(this._repository);

  // ---------------------------------------------------------------------------
  // TARGETS
  // ---------------------------------------------------------------------------
  Stream<List<TargetEntity>> watchTargets({bool includeArchived = false}) =>
      _repository.watchTargets(includeArchived: includeArchived);

  Future<void> createTarget(TargetsTableCompanion target) =>
      _repository.createTarget(target);

  Future<void> deleteTarget(String id) =>
      _repository.deleteTarget(id);

  // ---------------------------------------------------------------------------
  // TASKS
  // ---------------------------------------------------------------------------
  Stream<List<TaskEntity>> watchTasks() =>
      _repository.watchAllTasks();

  Future<void> createTask(TasksTableCompanion task) =>
      _repository.createTask(task);

  Future<void> toggleTask(TaskEntity task) =>
      _repository.toggleTaskCompletion(task);

  Future<void> deleteTask(String id) =>
      _repository.deleteTask(id);
}

