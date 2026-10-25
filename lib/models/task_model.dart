import 'package:flutter/material.dart';
import '../core/utils/date_utils.dart';

enum TaskStatus {
  todo,
  inProgress,
  done;

  String get title {
    switch (this) {
      case TaskStatus.todo:
        return 'Harus Dikerjakan';
      case TaskStatus.inProgress:
        return 'Sedang Dikerjakan';
      case TaskStatus.done:
        return 'Telah Selesai';
    }
  }

  String get shortTitle {
    switch (this) {
      case TaskStatus.todo:
        return 'Rencana';
      case TaskStatus.inProgress:
        return 'Proses';
      case TaskStatus.done:
        return 'Selesai';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.done:
        return Icons.check_circle_rounded;
    }
  }
}

enum TaskPriority {
  low('Rendah', Icons.arrow_downward_rounded),
  medium('Sedang', Icons.remove_rounded),
  high('Tinggi', Icons.arrow_upward_rounded);

  final String label;
  final IconData icon;
  const TaskPriority(this.label, this.icon);
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date; // Normalized to 00:00:00
  final TaskStatus status;
  final TaskPriority priority;
  final TimeOfDay? reminderTime;
  final DateTime createdAt;
  final int order;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required DateTime date,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.reminderTime,
    DateTime? createdAt,
    this.order = 0,
  })  : date = normalizeDate(date),
        createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TaskStatus? status,
    TaskPriority? priority,
    TimeOfDay? reminderTime,
    bool clearReminder = false,
    DateTime? createdAt,
    int? order,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date != null ? normalizeDate(date) : this.date,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': normalizeDate(date).toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminder;
    if (map['reminderHour'] != null && map['reminderMinute'] != null) {
      reminder = TimeOfDay(
        hour: map['reminderHour'] as int,
        minute: map['reminderMinute'] as int,
      );
    }

    final parsedDate = DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now();

    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: normalizeDate(parsedDate),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      reminderTime: reminder,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
