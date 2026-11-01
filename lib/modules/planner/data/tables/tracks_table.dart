import 'package:drift/drift.dart';
import 'targets_table.dart';

/// Tracks organize workstreams or categories within a Target.
@DataClassName('TrackEntity')
class TracksTable extends Table {
  @override
  String get tableName => 'tracks';

  TextColumn get id => text()();
  TextColumn get targetId => text().references(TargetsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
