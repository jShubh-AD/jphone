import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Central Drift Database for the JPhone offline ecosystem.
///
/// Configured with:
/// - Single-instance (Singleton) lifecycle to prevent database lock conflicts.
/// - Background isolate execution via [NativeDatabase.createInBackground].
/// - SQLite WAL (Write-Ahead Logging) mode for concurrent reads & writes.
/// - SQLite Foreign Key enforcement.
@DriftDatabase(
  tables: [
    // Sub-app feature tables will be registered here (e.g., PlannerTasks, Expenses)
  ],
  daos: [
    // Sub-app feature DAOs will be registered here
  ],
)
class AppDatabase extends _$AppDatabase {
  // Private constructor for Singleton
  AppDatabase._() : super(_openConnection());

  // Global Singleton instance
  static final AppDatabase instance = AppDatabase._();

  // Factory constructor returning the singleton
  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Incremental version migrations will be handled here (e.g., v1 -> v2)
    },
    beforeOpen: (OpeningDetails details) async {
      // Enforce foreign key constraints at the Drift connection level
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

/// Opens the SQLite database file in the app documents directory with WAL mode enabled.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'jphone.sqlite'));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // 1. Enable WAL mode: Allows reads and writes to execute concurrently
        rawDb.execute('PRAGMA journal_mode = WAL;');

        // 2. Recommended synchronization mode for WAL: avoids fsync overhead while protecting data
        rawDb.execute('PRAGMA synchronous = NORMAL;');

        // 3. Enforce relational integrity
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}
