import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/data/planner_local_datasource.dart';
import 'package:j_phone/modules/planner/data/planner_repository_impl.dart';
import 'package:j_phone/modules/planner/domain/planner_enums.dart';

void main() {
  late AppDatabase db;
  late PlannerRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final localDataSource = PlannerLocalDataSourceImpl(db.plannerDao);
    repository = PlannerRepositoryImpl(localDataSource);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlannerRepositoryImpl Tests', () {
    test('Create target, track, and task then toggle completion', () async {
      await repository.createTarget(
        TargetsTableCompanion.insert(
          id: 'target-repo-1',
          name: 'Build Offline Phone OS',
        ),
      );

      final targets = await repository.watchTargets().first;
      expect(targets.length, 1);
      expect(targets.first.id, 'target-repo-1');

      await repository.createTrack(
        TracksTableCompanion.insert(
          id: 'track-repo-1',
          targetId: 'target-repo-1',
          name: 'Core Module',
        ),
      );

      final tracks = await repository.watchTracksForTarget('target-repo-1').first;
      expect(tracks.length, 1);
      expect(tracks.first.name, 'Core Module');

      await repository.createTask(
        TasksTableCompanion.insert(
          id: 'task-repo-1',
          title: 'Implement Clean Arch Repo',
          targetId: const Value('target-repo-1'),
          trackId: const Value('track-repo-1'),
          status: const Value(TaskStatus.todo),
        ),
      );

      var tasks = await repository.watchAllTasks().first;
      expect(tasks.length, 1);
      expect(tasks.first.status, TaskStatus.todo);

      await repository.toggleTaskCompletion(tasks.first);
      tasks = await repository.watchAllTasks().first;
      expect(tasks.first.status, TaskStatus.completed);
      expect(tasks.first.completedAt, isNotNull);

      await repository.toggleTaskCompletion(tasks.first);
      tasks = await repository.watchAllTasks().first;
      expect(tasks.first.status, TaskStatus.todo);
      expect(tasks.first.completedAt, isNull);
    });
  });
}
