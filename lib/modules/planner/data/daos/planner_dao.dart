import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../tables/targets_table.dart';
import '../tables/tracks_table.dart';
import '../tables/tasks_table.dart';
import '../tables/steps_table.dart';
import '../tables/reminders_table.dart';

part 'planner_dao.g.dart';

/// Data Access Object for the Planner sub-app.
/// Encapsulates all reactive queries and mutations for Targets, Tracks, Tasks, Steps, and Reminders.
@DriftAccessor(tables: [
  TargetsTable,
  TracksTable,
  TasksTable,
  StepsTable,
  RemindersTable,
])
class PlannerDao extends DatabaseAccessor<AppDatabase> with _$PlannerDaoMixin {
  PlannerDao(super.db);

  // ---------------------------------------------------------------------------
  // TARGETS
  // ---------------------------------------------------------------------------
  Stream<List<TargetEntity>> watchAllTargets({bool includeArchived = false}) {
    final query = select(targetsTable);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<TargetEntity?> getTargetById(String id) {
    return (select(targetsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTarget(TargetsTableCompanion target) => into(targetsTable).insert(target);
  Future<bool> updateTarget(TargetEntity target) => update(targetsTable).replace(target);
  Future<int> deleteTarget(String id) => (delete(targetsTable)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // TRACKS
  // ---------------------------------------------------------------------------
  Stream<List<TrackEntity>> watchTracksForTarget(String targetId) {
    return (select(tracksTable)
          ..where((t) => t.targetId.equals(targetId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Future<int> insertTrack(TracksTableCompanion track) => into(tracksTable).insert(track);
  Future<bool> updateTrack(TrackEntity track) => update(tracksTable).replace(track);
  Future<int> deleteTrack(String id) => (delete(tracksTable)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // TASKS
  // ---------------------------------------------------------------------------
  Stream<List<TaskEntity>> watchAllTasks() {
    return (select(tasksTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isImportant, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<TaskEntity>> watchTasksForTarget(String targetId) {
    return (select(tasksTable)
          ..where((t) => t.targetId.equals(targetId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Stream<List<TaskEntity>> watchTasksForTrack(String trackId) {
    return (select(tasksTable)
          ..where((t) => t.trackId.equals(trackId))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch();
  }

  Future<TaskEntity?> getTaskById(String id) {
    return (select(tasksTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTask(TasksTableCompanion task) => into(tasksTable).insert(task);
  Future<bool> updateTask(TaskEntity task) => update(tasksTable).replace(task);
  Future<int> deleteTask(String id) => (delete(tasksTable)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // STEPS
  // ---------------------------------------------------------------------------
  Stream<List<StepEntity>> watchStepsForTask(String taskId) {
    return (select(stepsTable)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
        .watch();
  }

  Future<int> insertStep(StepsTableCompanion step) => into(stepsTable).insert(step);
  Future<bool> updateStep(StepEntity step) => update(stepsTable).replace(step);
  Future<int> deleteStep(String id) => (delete(stepsTable)..where((s) => s.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // REMINDERS
  // ---------------------------------------------------------------------------
  Stream<List<ReminderEntity>> watchRemindersForTask(String taskId) {
    return (select(remindersTable)..where((r) => r.taskId.equals(taskId))).watch();
  }

  Future<int> insertReminder(RemindersTableCompanion reminder) => into(remindersTable).insert(reminder);
  Future<int> deleteReminder(String id) => (delete(remindersTable)..where((r) => r.id.equals(id))).go();
}
