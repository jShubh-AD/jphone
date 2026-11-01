import 'package:drift/drift.dart';
import 'tasks_table.dart';

/// Steps represent smaller actionable items strictly belonging to a parent Task.
@DataClassName('StepEntity')
class StepsTable extends Table {
  @override
  String get tableName => 'steps';

  TextColumn get id => text()();
  TextColumn get taskId => text().references(TasksTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
