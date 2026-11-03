import 'package:j_phone/core/database/app_database.dart';
import 'daos/planner_dao.dart';

abstract class PlannerLocalDataSource {
  // Targets
  Stream<List<TargetEntity>> watchTargets({bool includeArchived = false});
  Future<TargetEntity?> getTargetById(String id);
  Future<int> insertTarget(TargetsTableCompanion target);
  Future<bool> updateTarget(TargetEntity target);
  Future<int> deleteTarget(String id);

  // Tracks
  Stream<List<TrackEntity>> watchTracksForTarget(String targetId);
  Future<int> insertTrack(TracksTableCompanion track);
  Future<bool> updateTrack(TrackEntity track);
  Future<int> deleteTrack(String id);

  // Tasks
  Stream<List<TaskEntity>> watchAllTasks();
  Stream<List<TaskEntity>> watchTasksForTarget(String targetId);
  Stream<List<TaskEntity>> watchTasksForTrack(String trackId);
  Future<TaskEntity?> getTaskById(String id);
  Future<int> insertTask(TasksTableCompanion task);
  Future<bool> updateTask(TaskEntity task);
  Future<int> deleteTask(String id);

  // Steps
  Stream<List<StepEntity>> watchStepsForTask(String taskId);
  Future<int> insertStep(StepsTableCompanion step);
  Future<bool> updateStep(StepEntity step);
  Future<int> deleteStep(String id);

  // Reminders
  Stream<List<ReminderEntity>> watchRemindersForTask(String taskId);
  Future<int> insertReminder(RemindersTableCompanion reminder);
  Future<int> deleteReminder(String id);
}

class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  final PlannerDao _dao;

  PlannerLocalDataSourceImpl(this._dao);

  @override
  Stream<List<TargetEntity>> watchTargets({bool includeArchived = false}) =>
      _dao.watchAllTargets(includeArchived: includeArchived);

  @override
  Future<TargetEntity?> getTargetById(String id) => _dao.getTargetById(id);

  @override
  Future<int> insertTarget(TargetsTableCompanion target) => _dao.insertTarget(target);

  @override
  Future<bool> updateTarget(TargetEntity target) => _dao.updateTarget(target);

  @override
  Future<int> deleteTarget(String id) => _dao.deleteTarget(id);

  @override
  Stream<List<TrackEntity>> watchTracksForTarget(String targetId) =>
      _dao.watchTracksForTarget(targetId);

  @override
  Future<int> insertTrack(TracksTableCompanion track) => _dao.insertTrack(track);

  @override
  Future<bool> updateTrack(TrackEntity track) => _dao.updateTrack(track);

  @override
  Future<int> deleteTrack(String id) => _dao.deleteTrack(id);

  @override
  Stream<List<TaskEntity>> watchAllTasks() => _dao.watchAllTasks();

  @override
  Stream<List<TaskEntity>> watchTasksForTarget(String targetId) =>
      _dao.watchTasksForTarget(targetId);

  @override
  Stream<List<TaskEntity>> watchTasksForTrack(String trackId) =>
      _dao.watchTasksForTrack(trackId);

  @override
  Future<TaskEntity?> getTaskById(String id) => _dao.getTaskById(id);

  @override
  Future<int> insertTask(TasksTableCompanion task) => _dao.insertTask(task);

  @override
  Future<bool> updateTask(TaskEntity task) => _dao.updateTask(task);

  @override
  Future<int> deleteTask(String id) => _dao.deleteTask(id);

  @override
  Stream<List<StepEntity>> watchStepsForTask(String taskId) =>
      _dao.watchStepsForTask(taskId);

  @override
  Future<int> insertStep(StepsTableCompanion step) => _dao.insertStep(step);

  @override
  Future<bool> updateStep(StepEntity step) => _dao.updateStep(step);

  @override
  Future<int> deleteStep(String id) => _dao.deleteStep(id);

  @override
  Stream<List<ReminderEntity>> watchRemindersForTask(String taskId) =>
      _dao.watchRemindersForTask(taskId);

  @override
  Future<int> insertReminder(RemindersTableCompanion reminder) =>
      _dao.insertReminder(reminder);

  @override
  Future<int> deleteReminder(String id) => _dao.deleteReminder(id);
}

