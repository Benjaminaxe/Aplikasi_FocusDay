import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../utils/date_utils.dart';

class StorageService {
  static const String _tasksKey = 'focusday_tasks_v1';
  static const String _hasSeededKey = 'focusday_has_seeded';
  static const String _themeModeKey = 'focusday_theme_mode';

  /// Load all tasks organized by normalized DateTime
  static Future<Map<DateTime, List<TaskModel>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_tasksKey);

    if (rawJson == null || rawJson.isEmpty) {
      final hasSeeded = prefs.getBool(_hasSeededKey) ?? false;
      if (!hasSeeded) {
        final initialTasks = _generateInitialSeed();
        await saveTasks(initialTasks);
        await prefs.setBool(_hasSeededKey, true);
        return initialTasks;
      }
      return {};
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(rawJson);
      final Map<DateTime, List<TaskModel>> result = {};

      decoded.forEach((dateKey, taskListRaw) {
        final date = DateTime.tryParse(dateKey);
        if (date != null && taskListRaw is List) {
          final normalized = normalizeDate(date);
          final tasks = taskListRaw
              .whereType<Map<String, dynamic>>()
              .map((m) => TaskModel.fromMap(m))
              .toList();

          result[normalized] = tasks;
        }
      });

      return result;
    } catch (e) {
      debugPrint('Error parsing saved tasks: $e');
      return {};
    }
  }

  /// Save all tasks to SharedPreferences
  static Future<void> saveTasks(Map<DateTime, List<TaskModel>> tasksMap) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> mapToSave = {};

    tasksMap.forEach((date, taskList) {
      final normalized = normalizeDate(date);
      final key = normalized.toIso8601String();
      mapToSave[key] = taskList.map((t) => t.toMap()).toList();
    });

    final jsonStr = jsonEncode(mapToSave);
    await prefs.setString(_tasksKey, jsonStr);
  }

  /// Save and load theme mode preference
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == ThemeMode.dark.name) return ThemeMode.dark;
    if (raw == ThemeMode.light.name) return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Initial friendly seed data for demonstration and immediate visual delight
  static Map<DateTime, List<TaskModel>> _generateInitialSeed() {
    final today = normalizeDate(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 3));

    final Map<DateTime, List<TaskModel>> seed = {
      today: [
        TaskModel(
          id: 'seed-1',
          title: 'Review proposal proyek FocusDay',
          description: 'Cek integrasi table_calendar dan Kanban board di POCO F7',
          date: today,
          status: TaskStatus.inProgress,
          priority: TaskPriority.high,
          reminderTime: const TimeOfDay(hour: 16, minute: 0),
          order: 0,
        ),
        TaskModel(
          id: 'seed-2',
          title: 'Olahraga sore 30 menit',
          description: 'Jogging santai di taman lingkungan',
          date: today,
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          reminderTime: const TimeOfDay(hour: 17, minute: 30),
          order: 1,
        ),
        TaskModel(
          id: 'seed-3',
          title: 'Rapat sinkronisasi pagi',
          description: 'Bahas roadmap sprint mingguan dengan tim desain',
          date: today,
          status: TaskStatus.done,
          priority: TaskPriority.medium,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          order: 2,
        ),
      ],
      tomorrow: [
        TaskModel(
          id: 'seed-4',
          title: 'Uji performa 120Hz & animasi',
          description: 'Pastikan transisi kalender super responsif dan halus',
          date: tomorrow,
          status: TaskStatus.todo,
          priority: TaskPriority.high,
          reminderTime: const TimeOfDay(hour: 10, minute: 0),
          order: 0,
        ),
        TaskModel(
          id: 'seed-5',
          title: 'Membaca buku produktivitas 2 bab',
          description: 'Atomic Habits - Bab identitas dan konsistensi',
          date: tomorrow,
          status: TaskStatus.todo,
          priority: TaskPriority.low,
          order: 1,
        ),
      ],
      yesterday: [
        TaskModel(
          id: 'seed-6',
          title: 'Setup arsitektur Riverpod & SQLite/Prefs',
          description: 'Normalisasi DateTime 00:00:00 untuk Calendar Binding',
          date: yesterday,
          status: TaskStatus.done,
          priority: TaskPriority.high,
          order: 0,
        ),
      ],
      nextWeek: [
        TaskModel(
          id: 'seed-7',
          title: 'Evaluasi jadwal mingguan',
          description: 'Rekap tugas terselesaikan dari kalender',
          date: nextWeek,
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          order: 0,
        ),
      ],
    };

    return seed;
  }
}
