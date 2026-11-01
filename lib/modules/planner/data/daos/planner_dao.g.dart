// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planner_dao.dart';

// ignore_for_file: type=lint
mixin _$PlannerDaoMixin on DatabaseAccessor<AppDatabase> {
  $TargetsTableTable get targetsTable => attachedDatabase.targetsTable;
  $TracksTableTable get tracksTable => attachedDatabase.tracksTable;
  $TasksTableTable get tasksTable => attachedDatabase.tasksTable;
  $StepsTableTable get stepsTable => attachedDatabase.stepsTable;
  $RemindersTableTable get remindersTable => attachedDatabase.remindersTable;
  PlannerDaoManager get managers => PlannerDaoManager(this);
}

class PlannerDaoManager {
  final _$PlannerDaoMixin _db;
  PlannerDaoManager(this._db);
  $$TargetsTableTableTableManager get targetsTable =>
      $$TargetsTableTableTableManager(_db.attachedDatabase, _db.targetsTable);
  $$TracksTableTableTableManager get tracksTable =>
      $$TracksTableTableTableManager(_db.attachedDatabase, _db.tracksTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db.attachedDatabase, _db.tasksTable);
  $$StepsTableTableTableManager get stepsTable =>
      $$StepsTableTableTableManager(_db.attachedDatabase, _db.stepsTable);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(
        _db.attachedDatabase,
        _db.remindersTable,
      );
}
