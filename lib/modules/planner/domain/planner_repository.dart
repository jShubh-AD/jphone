import 'package:j_phone/core/database/app_database.dart';

abstract class PlannerRepository {
  // Targets
  Stream<List<TargetEntity>> watchTargets({bool includeArchived = false});
  Future<TargetEntity?> getTargetById(String id);
  Future<void> createTarget(TargetsTableCompanion target);
  Future<void> updateTarget(TargetEntity target);
  Future<void> deleteTarget(String id);

  // Tracks
  Stream<List<TrackEntity>> watchTracksForTarget(String targetId);
  Future<void> createTrack(TracksTableCompanion track);
  Future<void> updateTrack(TrackEntity track);
  Future<void> deleteTrack(String id);

  // Tasks
  Stream<List<TaskEntity>> watchAllTasks();
  Stream<List<TaskEntity>> watchTasksForTarget(String targetId);
  Stream<List<TaskEntity>> watchTasksForTrack(String trackId);
  Future<TaskEntity?> getTaskById(String id);
  Future<void> createTask(TasksTableCompanion task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(TaskEntity task);

  // Steps
  Stream<List<StepEntity>> watchStepsForTask(String taskId);
  Future<void> createStep(StepsTableCompanion step);
  Future<void> updateStep(StepEntity step);
  Future<void> deleteStep(String id);
  Future<void> toggleStepCompletion(StepEntity step);

  // Reminders
  Stream<List<ReminderEntity>> watchRemindersForTask(String taskId);
  Future<void> createReminder(RemindersTableCompanion reminder);
  Future<void> deleteReminder(String id);
}

