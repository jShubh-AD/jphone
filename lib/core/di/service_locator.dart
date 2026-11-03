import 'package:get_it/get_it.dart';
import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/data/daos/planner_dao.dart';
import 'package:j_phone/modules/planner/data/planner_local_datasource.dart';
import 'package:j_phone/modules/planner/data/planner_repository_impl.dart';
import 'package:j_phone/modules/planner/domain/planner_repository.dart';
import 'package:j_phone/modules/planner/domain/planner_usecases.dart';
import 'package:j_phone/modules/planner/presentation/bloc/planner_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({AppDatabase? database}) async {
  // 1. Database instance (Singleton)
  final db = database ?? AppDatabase.instance;
  sl.registerSingleton<AppDatabase>(db);

  // 2. DAOs
  sl.registerLazySingleton<PlannerDao>(() => sl<AppDatabase>().plannerDao);

  // 3. Data Sources
  sl.registerLazySingleton<PlannerLocalDataSource>(
    () => PlannerLocalDataSourceImpl(sl<PlannerDao>()),
  );

  // 4. Repositories
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(sl<PlannerLocalDataSource>()),
  );

  // 5. Use Cases (Single unified class)
  sl.registerLazySingleton<PlannerUseCases>(
    () => PlannerUseCases(sl<PlannerRepository>()),
  );

  // 6. Blocs (LazySingleton so whole app shares state & streams)
  sl.registerLazySingleton<PlannerBloc>(
    () => PlannerBloc(sl<PlannerUseCases>()),
  );
}
