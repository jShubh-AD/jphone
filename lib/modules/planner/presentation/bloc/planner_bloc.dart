import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:j_phone/core/database/app_database.dart';
import 'package:j_phone/modules/planner/domain/planner_usecases.dart';
import 'planner_event.dart';
import 'planner_state.dart';

export 'planner_event.dart';
export 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final PlannerUseCases _useCases;
  final Uuid _uuid;

  StreamSubscription<List<TargetEntity>>? _targetsSubscription;
  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  List<TargetEntity> _cachedTargets = [];
  List<TaskEntity> _cachedTasks = [];
  String? _selectedTargetId;

  PlannerBloc(this._useCases, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(const PlannerInitial()) {
    on<PlannerStarted>(_onStarted);
    on<PlannerTargetsUpdated>(_onTargetsUpdated);
    on<PlannerTasksUpdated>(_onTasksUpdated);
    on<PlannerTargetSelected>(_onTargetSelected);
    on<PlannerTaskToggled>(_onTaskToggled);
    on<PlannerTargetCreated>(_onTargetCreated);
    on<PlannerTaskCreated>(_onTaskCreated);
    on<PlannerTaskDeleted>(_onTaskDeleted);
    on<PlannerTargetDeleted>(_onTargetDeleted);

    add(const PlannerStarted());
  }

  void _onStarted(PlannerStarted event, Emitter<PlannerState> emit) {
    emit(const PlannerLoading());

    _targetsSubscription?.cancel();
    _targetsSubscription = _useCases.watchTargets().listen(
      (targets) => add(PlannerTargetsUpdated(targets)),
      onError: (e) => emit(PlannerError(e.toString())),
    );

    _tasksSubscription?.cancel();
    _tasksSubscription = _useCases.watchTasks().listen(
      (tasks) => add(PlannerTasksUpdated(tasks)),
      onError: (e) => emit(PlannerError(e.toString())),
    );
  }

  void _onTargetsUpdated(PlannerTargetsUpdated event, Emitter<PlannerState> emit) {
    _cachedTargets = event.targets;
    _emitLoaded(emit);
  }

  void _onTasksUpdated(PlannerTasksUpdated event, Emitter<PlannerState> emit) {
    _cachedTasks = event.tasks;
    _emitLoaded(emit);
  }

  void _onTargetSelected(PlannerTargetSelected event, Emitter<PlannerState> emit) {
    _selectedTargetId = event.targetId;
    _emitLoaded(emit);
  }

  Future<void> _onTaskToggled(PlannerTaskToggled event, Emitter<PlannerState> emit) async {
    try {
      await _useCases.toggleTask(event.task);
    } catch (e) {
      emit(PlannerError('Failed to update task: $e'));
      _emitLoaded(emit);
    }
  }

  Future<void> _onTargetCreated(PlannerTargetCreated event, Emitter<PlannerState> emit) async {
    try {
      final companion = TargetsTableCompanion.insert(
        id: _uuid.v4(),
        name: event.name,
        description: Value(event.description),
        color: Value(event.color),
        icon: Value(event.icon),
        deadline: Value(event.deadline),
      );
      await _useCases.createTarget(companion);
    } catch (e) {
      emit(PlannerError('Failed to create target: $e'));
      _emitLoaded(emit);
    }
  }

  Future<void> _onTaskCreated(PlannerTaskCreated event, Emitter<PlannerState> emit) async {
    try {
      final companion = TasksTableCompanion.insert(
        id: _uuid.v4(),
        title: event.title,
        description: Value(event.description),
        targetId: Value(event.targetId),
        trackId: Value(event.trackId),
        priority: Value(event.priority),
        isImportant: Value(event.isImportant),
        dueDate: Value(event.dueDate),
      );
      await _useCases.createTask(companion);
    } catch (e) {
      emit(PlannerError('Failed to create task: $e'));
      _emitLoaded(emit);
    }
  }

  Future<void> _onTaskDeleted(PlannerTaskDeleted event, Emitter<PlannerState> emit) async {
    try {
      await _useCases.deleteTask(event.id);
    } catch (e) {
      emit(PlannerError('Failed to delete task: $e'));
      _emitLoaded(emit);
    }
  }

  Future<void> _onTargetDeleted(PlannerTargetDeleted event, Emitter<PlannerState> emit) async {
    try {
      if (_selectedTargetId == event.id) {
        _selectedTargetId = null;
      }
      await _useCases.deleteTarget(event.id);
    } catch (e) {
      emit(PlannerError('Failed to delete target: $e'));
      _emitLoaded(emit);
    }
  }

  void _emitLoaded(Emitter<PlannerState> emit) {
    emit(PlannerLoaded(
      targets: _cachedTargets,
      tasks: _cachedTasks,
      selectedTargetId: _selectedTargetId,
    ));
  }

  @override
  Future<void> close() {
    _targetsSubscription?.cancel();
    _tasksSubscription?.cancel();
    return super.close();
  }
}
