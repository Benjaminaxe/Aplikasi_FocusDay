import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import 'calendar_provider.dart';

class TaskNotifier extends Notifier<Map<DateTime, List<TaskModel>>> {
  @override
  Map<DateTime, List<TaskModel>> build() {
    _loadFromStorage();
    return {};
  }

  Future<void> _loadFromStorage() async {
    final loaded = await StorageService.loadTasks();
    state = loaded;
  }

  Future<void> addTask(TaskModel task) async {
    final normalized = normalizeDate(task.date);
    final currentList = List<TaskModel>.from(state[normalized] ?? []);

    // Set order to end of list
    final newTask = task.copyWith(
      order: currentList.length,
      date: normalized,
    );

    currentList.add(newTask);

    final newState = Map<DateTime, List<TaskModel>>.from(state);
    newState[normalized] = currentList;
    state = newState;

    await StorageService.saveTasks(newState);

    if (newTask.reminderTime != null) {
      await NotificationService.instance.scheduleTaskReminder(
        taskId: newTask.id,
        title: newTask.title,
        body: newTask.description,
        date: newTask.date,
        time: newTask.reminderTime!,
      );
    }
  }

  Future<void> updateTask(TaskModel updated) async {
    final normalized = normalizeDate(updated.date);
    final currentList = List<TaskModel>.from(state[normalized] ?? []);
    final index = currentList.indexWhere((t) => t.id == updated.id);

    if (index != -1) {
      currentList[index] = updated;
      final newState = Map<DateTime, List<TaskModel>>.from(state);
      newState[normalized] = currentList;
      state = newState;

      await StorageService.saveTasks(newState);

      // Reschedule or cancel notification
      if (updated.reminderTime != null) {
        await NotificationService.instance.scheduleTaskReminder(
          taskId: updated.id,
          title: updated.title,
          body: updated.description,
          date: updated.date,
          time: updated.reminderTime!,
        );
      } else {
        await NotificationService.instance.cancelReminder(updated.id);
      }
    }
  }

  Future<void> deleteTask(String id, DateTime date) async {
    final normalized = normalizeDate(date);
    final currentList = List<TaskModel>.from(state[normalized] ?? []);
    currentList.removeWhere((t) => t.id == id);

    final newState = Map<DateTime, List<TaskModel>>.from(state);
    if (currentList.isEmpty) {
      newState.remove(normalized);
    } else {
      newState[normalized] = currentList;
    }
    state = newState;

    await StorageService.saveTasks(newState);
    await NotificationService.instance.cancelReminder(id);
  }

  Future<void> moveTaskStatus(
    String id,
    DateTime date,
    TaskStatus newStatus,
  ) async {
    final normalized = normalizeDate(date);
    final currentList = List<TaskModel>.from(state[normalized] ?? []);
    final index = currentList.indexWhere((t) => t.id == id);

    if (index != -1) {
      final oldTask = currentList[index];
      if (oldTask.status == newStatus) return;

      final updated = oldTask.copyWith(status: newStatus);
      currentList[index] = updated;

      final newState = Map<DateTime, List<TaskModel>>.from(state);
      newState[normalized] = currentList;
      state = newState;

      await StorageService.saveTasks(newState);
    }
  }

  Future<void> reorderInStatus(
    DateTime date,
    TaskStatus status,
    int oldIndex,
    int newIndex,
  ) async {
    final normalized = normalizeDate(date);
    final allList = List<TaskModel>.from(state[normalized] ?? []);
    final statusList = allList.where((t) => t.status == status).toList();

    if (oldIndex < 0 || oldIndex >= statusList.length) return;
    if (newIndex < 0 || newIndex > statusList.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = statusList.removeAt(oldIndex);
    statusList.insert(newIndex, item);

    // Rebuild order
    final otherList = allList.where((t) => t.status != status).toList();
    final combined = <TaskModel>[...otherList, ...statusList];

    final newState = Map<DateTime, List<TaskModel>>.from(state);
    newState[normalized] = combined;
    state = newState;

    await StorageService.saveTasks(newState);
  }

  /// Bulk move or clear completed tasks
  Future<void> clearCompleted(DateTime date) async {
    final normalized = normalizeDate(date);
    final currentList = List<TaskModel>.from(state[normalized] ?? []);
    final removed = currentList.where((t) => t.status == TaskStatus.done).toList();
    currentList.removeWhere((t) => t.status == TaskStatus.done);

    final newState = Map<DateTime, List<TaskModel>>.from(state);
    if (currentList.isEmpty) {
      newState.remove(normalized);
    } else {
      newState[normalized] = currentList;
    }
    state = newState;

    await StorageService.saveTasks(newState);
    for (final task in removed) {
      await NotificationService.instance.cancelReminder(task.id);
    }
  }
}

final taskNotifierProvider =
    NotifierProvider<TaskNotifier, Map<DateTime, List<TaskModel>>>(TaskNotifier.new);

/// Tasks strictly bound to the currently selected calendar date
final selectedDateTasksProvider = Provider<List<TaskModel>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final allTasks = ref.watch(taskNotifierProvider);
  final normalized = normalizeDate(selectedDate);
  return allTasks[normalized] ?? const [];
});

/// Harus Dikerjakan (To-Do) tasks for selected date
final todoTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(selectedDateTasksProvider);
  return tasks.where((t) => t.status == TaskStatus.todo).toList();
});

/// Sedang Dikerjakan (In-Progress) tasks for selected date
final inProgressTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(selectedDateTasksProvider);
  return tasks.where((t) => t.status == TaskStatus.inProgress).toList();
});

/// Telah Selesai (Done) tasks for selected date
final doneTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(selectedDateTasksProvider);
  return tasks.where((t) => t.status == TaskStatus.done).toList();
});

/// Fast event loader callback for TableCalendar
final calendarEventsLoaderProvider =
    Provider<List<TaskModel> Function(DateTime)>((ref) {
  final allTasks = ref.watch(taskNotifierProvider);
  return (DateTime day) {
    final normalized = normalizeDate(day);
    return allTasks[normalized] ?? const [];
  };
});
