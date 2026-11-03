import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/quick_link_item.dart';
import '../domain/models/habit_streak_item.dart';
import '../domain/models/memo_note_item.dart';

class DashboardLocalStorage {
  static const String _keyQuickLinks = 'jphone_quick_links_v1';
  static const String _keyHabitStreaks = 'jphone_habit_streaks_v1';
  static const String _keyMemos = 'jphone_memos_v1';

  // Focus timer keys
  static const String _keyFocusRunning = 'jphone_focus_is_running';
  static const String _keyFocusEndTime = 'jphone_focus_target_end_time';
  static const String _keyFocusRemaining = 'jphone_focus_remaining_seconds';
  static const String _keyFocusTaskId = 'jphone_focus_task_id';
  static const String _keyFocusTaskTitle = 'jphone_focus_task_title';
  static const String _keyFocusTaskDesc = 'jphone_focus_task_desc';
  static const String _keyFocusDurationMinutes = 'jphone_focus_duration_minutes';

  // ---------------------------------------------------------------------------
  // Quick Links
  // ---------------------------------------------------------------------------
  Future<List<QuickLinkItem>> getQuickLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyQuickLinks);
    if (jsonStr == null || jsonStr.isEmpty) {
      return QuickLinkItem.defaultShortcuts;
    }
    return QuickLinkItem.decodeList(jsonStr);
  }

  Future<void> saveQuickLinks(List<QuickLinkItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyQuickLinks, QuickLinkItem.encodeList(items));
  }

  // ---------------------------------------------------------------------------
  // Habit Streaks
  // ---------------------------------------------------------------------------
  Future<List<HabitStreakItem>> getHabitStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyHabitStreaks);
    if (jsonStr == null || jsonStr.isEmpty) {
      return HabitStreakItem.defaultHabits;
    }
    return HabitStreakItem.decodeList(jsonStr);
  }

  Future<void> saveHabitStreaks(List<HabitStreakItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHabitStreaks, HabitStreakItem.encodeList(items));
  }

  Future<List<HabitStreakItem>> incrementHabit(String id, double delta) async {
    final list = await getHabitStreaks();
    final index = list.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = list[index];
      final newCurrent = (habit.current + delta).clamp(0.0, habit.target * 2);
      final updated = habit.copyWith(current: newCurrent);
      list[index] = updated;
      await saveHabitStreaks(list);
    }
    return list;
  }

  // ---------------------------------------------------------------------------
  // Quick Memos
  // ---------------------------------------------------------------------------
  Future<List<MemoNoteItem>> getMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyMemos);
    if (jsonStr == null || jsonStr.isEmpty) {
      return MemoNoteItem.defaultNotes;
    }
    return MemoNoteItem.decodeList(jsonStr);
  }

  Future<void> saveMemos(List<MemoNoteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMemos, MemoNoteItem.encodeList(items));
  }

  Future<void> saveMemo(MemoNoteItem memo) async {
    final list = await getMemos();
    final index = list.indexWhere((m) => m.id == memo.id);
    if (index != -1) {
      list[index] = memo;
    } else {
      list.insert(0, memo);
    }
    await saveMemos(list);
  }

  Future<void> deleteMemo(String id) async {
    final list = await getMemos();
    list.removeWhere((m) => m.id == id);
    await saveMemos(list);
  }

  // ---------------------------------------------------------------------------
  // Focus Timer State
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getFocusTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(_keyFocusRunning) ?? false;
    final endTimeEpoch = prefs.getInt(_keyFocusEndTime);
    final remainingStored = prefs.getInt(_keyFocusRemaining) ?? (25 * 60);
    final taskId = prefs.getString(_keyFocusTaskId);
    final taskTitle = prefs.getString(_keyFocusTaskTitle) ?? 'Design JPhone design system';
    final taskDesc = prefs.getString(_keyFocusTaskDesc) ?? 'Refine typography, spacing, and micro-interactions for production.';
    final durationMinutes = prefs.getInt(_keyFocusDurationMinutes) ?? 25;

    int effectiveRemaining = remainingStored;
    bool effectiveRunning = isRunning;

    if (isRunning && endTimeEpoch != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeEpoch);
      final diffSeconds = endTime.difference(DateTime.now()).inSeconds;
      if (diffSeconds <= 0) {
        effectiveRemaining = 0;
        effectiveRunning = false;
        await prefs.setBool(_keyFocusRunning, false);
        await prefs.setInt(_keyFocusRemaining, 0);
      } else {
        effectiveRemaining = diffSeconds;
      }
    }

    return {
      'isRunning': effectiveRunning,
      'remainingSeconds': effectiveRemaining,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'taskDesc': taskDesc,
      'durationMinutes': durationMinutes,
    };
  }

  Future<void> saveFocusTimerState({
    required bool isRunning,
    required int remainingSeconds,
    String? taskId,
    String? taskTitle,
    String? taskDesc,
    int? durationMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFocusRunning, isRunning);
    await prefs.setInt(_keyFocusRemaining, remainingSeconds);

    if (isRunning) {
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
      await prefs.setInt(_keyFocusEndTime, endTime.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_keyFocusEndTime);
    }

    if (taskId != null) await prefs.setString(_keyFocusTaskId, taskId);
    if (taskTitle != null) await prefs.setString(_keyFocusTaskTitle, taskTitle);
    if (taskDesc != null) await prefs.setString(_keyFocusTaskDesc, taskDesc);
    if (durationMinutes != null) await prefs.setInt(_keyFocusDurationMinutes, durationMinutes);
  }
}

