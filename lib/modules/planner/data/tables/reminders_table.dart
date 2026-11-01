import 'package:drift/drift.dart';
import 'tasks_table.dart';
import 'steps_table.dart';

/// Reminders reference either a Task or a Step.
@DataClassName('ReminderEntity')
class RemindersTable extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get taskId => text().nullable().references(TasksTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get stepId => text().nullable().references(StepsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get remindAt => dateTime()();
  TextColumn get repeatConfig => text().nullable()(); // JSON string or RRule
  TextColumn get soundConfig => text().nullable()();
  TextColumn get vibrationConfig => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
