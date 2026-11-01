import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/domain/enums/planner_enums.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Isolated in-memory database for unit testing (blazing fast, zero disk I/O)
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Planner Database & DAO Tests', () {
    test('Can insert and stream targets, tracks, and tasks', () async {
      final dao = db.plannerDao;

      // 1. Insert a Target
      await dao.insertTarget(
        TargetsTableCompanion.insert(
          id: 'target-1',
          name: 'Launch JPhone',
          description: const Value('Build offline phone OS'),
        ),
      );

      final targets = await dao.watchAllTargets().first;
      expect(targets.length, 1);
      expect(targets.first.name, 'Launch JPhone');

      // 2. Insert a Track under the Target
      await dao.insertTrack(
        TracksTableCompanion.insert(
          id: 'track-1',
          targetId: 'target-1',
          name: 'Architecture',
        ),
      );

      final tracks = await dao.watchTracksForTarget('target-1').first;
      expect(tracks.length, 1);
      expect(tracks.first.name, 'Architecture');

      // 3. Insert a Task under the Track & Target
      await dao.insertTask(
        TasksTableCompanion.insert(
          id: 'task-1',
          title: 'Implement Drift DB',
          targetId: const Value('target-1'),
          trackId: const Value('track-1'),
          priority: const Value(TaskPriority.high),
          isImportant: const Value(true),
        ),
      );

      final tasks = await dao.watchAllTasks().first;
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Implement Drift DB');
      expect(tasks.first.priority, TaskPriority.high);
      expect(tasks.first.isImportant, isTrue);

      // 4. Insert Steps for the Task
      await dao.insertStep(
        StepsTableCompanion.insert(
          id: 'step-1',
          taskId: 'task-1',
          title: 'Define tables',
          isCompleted: const Value(true),
        ),
      );

      final steps = await dao.watchStepsForTask('task-1').first;
      expect(steps.length, 1);
      expect(steps.first.title, 'Define tables');
      expect(steps.first.isCompleted, isTrue);
    });
  });
}
