import 'package:flutter/material.dart';

/// Normalize any DateTime to 00:00:00.000 for consistent Calendar Binding
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Check if two dates represent the exact same calendar day
bool isSameCalendarDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Format date to Indonesian localized representation e.g. "Senin, 25 Okt 2026"
String formatFullDateIndonesian(DateTime date) {
  const dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final dayName = dayNames[date.weekday - 1];
  final monthName = monthNames[date.month - 1];

  return '$dayName, ${date.day} $monthName ${date.year}';
}

/// Short format e.g. "25 Okt"
String formatShortDate(DateTime date) {
  const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${monthNames[date.month - 1]}';
}

/// Friendly relative date label e.g. "Hari Ini", "Besok", "Kemarin"
String getRelativeDateLabel(DateTime date) {
  final today = normalizeDate(DateTime.now());
  final target = normalizeDate(date);
  final diffDays = target.difference(today).inDays;

  if (diffDays == 0) return 'Hari Ini';
  if (diffDays == 1) return 'Besok';
  if (diffDays == -1) return 'Kemarin';

  const dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  return dayNames[date.weekday - 1];
}

/// Format TimeOfDay to 24-hour string "HH:mm"
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
