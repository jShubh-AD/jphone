import 'package:drift/drift.dart';
import '../../domain/enums/planner_enums.dart';
import 'targets_table.dart';
import 'tracks_table.dart';

/// Tasks represent actionable units of work.
/// Can belong to a Target and optionally a Track, or exist independently.
@DataClassName('TaskEntity')
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  TextColumn get id => text()();
  TextColumn get targetId => text().nullable().references(TargetsTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get trackId => text().nullable().references(TracksTable, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();
  IntColumn get status => intEnum<TaskStatus>().withDefault(Constant(TaskStatus.todo.index))();
  IntColumn get priority => intEnum<TaskPriority>().withDefault(Constant(TaskPriority.medium.index))();
  BoolColumn get isImportant => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
