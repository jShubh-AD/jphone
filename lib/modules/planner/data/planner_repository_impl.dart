import 'package:drift/drift.dart' show Value;
import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/data/planner_local_datasource.dart';
import 'package:j_phone/modules/planner/domain/planner_enums.dart';
import 'package:j_phone/modules/planner/domain/planner_repository.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDataSource _localDataSource;

  PlannerRepositoryImpl(this._localDataSource);

  // ---------------------------------------------------------------------------
  // TARGETS
  // ---------------------------------------------------------------------------
  @override
  Stream<List<TargetEntity>> watchTargets({bool includeArchived = false}) {
    return _localDataSource.watchTargets(includeArchived: includeArchived);
  }

  @override
  Future<TargetEntity?> getTargetById(String id) {
    return _localDataSource.getTargetById(id);
  }

  @override
  Future<void> createTarget(TargetsTableCompanion target) async {
    await _localDataSource.insertTarget(target);
  }

  @override
  Future<void> updateTarget(TargetEntity target) async {
    await _localDataSource.updateTarget(target);
  }

  @override
  Future<void> deleteTarget(String id) async {
    await _localDataSource.deleteTarget(id);
  }

  // ---------------------------------------------------------------------------
  // TRACKS
  // ---------------------------------------------------------------------------
  @override
  Stream<List<TrackEntity>> watchTracksForTarget(String targetId) {
    return _localDataSource.watchTracksForTarget(targetId);
  }

  @override
  Future<void> createTrack(TracksTableCompanion track) async {
    await _localDataSource.insertTrack(track);
  }

  @override
  Future<void> updateTrack(TrackEntity track) async {
    await _localDataSource.updateTrack(track);
  }

  @override
  Future<void> deleteTrack(String id) async {
    await _localDataSource.deleteTrack(id);
  }

  // ---------------------------------------------------------------------------
  // TASKS
  // ---------------------------------------------------------------------------
  @override
  Stream<List<TaskEntity>> watchAllTasks() {
    return _localDataSource.watchAllTasks();
  }

  @override
  Stream<List<TaskEntity>> watchTasksForTarget(String targetId) {
    return _localDataSource.watchTasksForTarget(targetId);
  }

  @override
  Stream<List<TaskEntity>> watchTasksForTrack(String trackId) {
    return _localDataSource.watchTasksForTrack(trackId);
  }

  @override
  Future<TaskEntity?> getTaskById(String id) {
    return _localDataSource.getTaskById(id);
  }

  @override
  Future<void> createTask(TasksTableCompanion task) async {
    await _localDataSource.insertTask(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _localDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(TaskEntity task) async {
    final isDone = task.status == TaskStatus.completed;
    final updated = task.copyWith(
      status: isDone ? TaskStatus.todo : TaskStatus.completed,
      completedAt: Value(isDone ? null : DateTime.now()),
      updatedAt: DateTime.now(),
    );
    await _localDataSource.updateTask(updated);
  }

  // ---------------------------------------------------------------------------
  // STEPS
  // ---------------------------------------------------------------------------
  @override
  Stream<List<StepEntity>> watchStepsForTask(String taskId) {
    return _localDataSource.watchStepsForTask(taskId);
  }

  @override
  Future<void> createStep(StepsTableCompanion step) async {
    await _localDataSource.insertStep(step);
  }

  @override
  Future<void> updateStep(StepEntity step) async {
    await _localDataSource.updateStep(step);
  }

  @override
  Future<void> deleteStep(String id) async {
    await _localDataSource.deleteStep(id);
  }

  @override
  Future<void> toggleStepCompletion(StepEntity step) async {
    final updated = step.copyWith(
      isCompleted: !step.isCompleted,
    );
    await _localDataSource.updateStep(updated);
  }

  // ---------------------------------------------------------------------------
  // REMINDERS
  // ---------------------------------------------------------------------------
  @override
  Stream<List<ReminderEntity>> watchRemindersForTask(String taskId) {
    return _localDataSource.watchRemindersForTask(taskId);
  }

  @override
  Future<void> createReminder(RemindersTableCompanion reminder) async {
    await _localDataSource.insertReminder(reminder);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _localDataSource.deleteReminder(id);
  }
}

