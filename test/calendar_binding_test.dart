import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasi_focusday/core/utils/date_utils.dart';
import 'package:aplikasi_focusday/models/task_model.dart';

void main() {
  group('Calendar Binding & Date Normalization Tests', () {
    test('normalizeDate removes hour, minute, second, and millisecond', () {
      final now = DateTime(2026, 10, 25, 15, 45, 30, 500);
      final normalized = normalizeDate(now);

      expect(normalized.year, equals(2026));
      expect(normalized.month, equals(10));
      expect(normalized.day, equals(25));
      expect(normalized.hour, equals(0));
      expect(normalized.minute, equals(0));
      expect(normalized.second, equals(0));
      expect(normalized.millisecond, equals(0));
    });

    test('isSameCalendarDay matches dates with different times', () {
      final dateA = DateTime(2026, 10, 25, 8, 30);
      final dateB = DateTime(2026, 10, 25, 23, 59);
      final dateC = DateTime(2026, 10, 26, 0, 1);

      expect(isSameCalendarDay(dateA, dateB), isTrue);
      expect(isSameCalendarDay(dateA, dateC), isFalse);
    });

    test('TaskModel automatically normalizes its date on creation and copyWith', () {
      final inputDate = DateTime(2026, 10, 25, 14, 20);
      final task = TaskModel(
        id: 't-1',
        title: 'Kerjakan Kanban Flutter',
        date: inputDate,
        status: TaskStatus.todo,
        reminderTime: const TimeOfDay(hour: 16, minute: 30),
      );

      expect(task.date.hour, equals(0));
      expect(task.date.minute, equals(0));

      final movedDate = DateTime(2026, 10, 28, 19, 0);
      final updatedTask = task.copyWith(
        date: movedDate,
        status: TaskStatus.inProgress,
      );

      expect(updatedTask.date.hour, equals(0));
      expect(updatedTask.date.day, equals(28));
      expect(updatedTask.status, equals(TaskStatus.inProgress));
    });

    test('TaskModel serialization and deserialization preserves all attributes', () {
      final task = TaskModel(
        id: 't-serialize',
        title: 'Review POCO F7 120Hz display',
        description: 'Pastikan animasi responsif',
        date: DateTime(2026, 10, 25, 10, 0),
        status: TaskStatus.done,
        priority: TaskPriority.high,
        reminderTime: const TimeOfDay(hour: 17, minute: 0),
      );

      final map = task.toMap();
      final revived = TaskModel.fromMap(map);

      expect(revived.id, equals(task.id));
      expect(revived.title, equals(task.title));
      expect(revived.description, equals(task.description));
      expect(revived.status, equals(TaskStatus.done));
      expect(revived.priority, equals(TaskPriority.high));
      expect(revived.reminderTime?.hour, equals(17));
      expect(revived.reminderTime?.minute, equals(0));
      expect(isSameCalendarDay(revived.date, task.date), isTrue);
    });

    test('Calendar mapping Map<DateTime, List<TaskModel>> groups tasks correctly', () {
      final date1 = normalizeDate(DateTime(2026, 10, 25));
      final date2 = normalizeDate(DateTime(2026, 10, 26));

      final Map<DateTime, List<TaskModel>> calendarMap = {};

      final taskA = TaskModel(id: '1', title: 'Task A', date: date1);
      final taskB = TaskModel(id: '2', title: 'Task B', date: date1, status: TaskStatus.inProgress);
      final taskC = TaskModel(id: '3', title: 'Task C', date: date2, status: TaskStatus.done);

      calendarMap[date1] = [taskA, taskB];
      calendarMap[date2] = [taskC];

      expect(calendarMap[date1]?.length, equals(2));
      expect(calendarMap[date2]?.length, equals(1));
      expect(calendarMap[normalizeDate(DateTime(2026, 10, 27))], isNull);
    });
  });
}
