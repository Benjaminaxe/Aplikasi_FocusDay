import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;
import '../core/utils/date_utils.dart';

class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat format;

  const CalendarState({
    required this.selectedDate,
    required this.focusedDate,
    required this.format,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    CalendarFormat? format,
  }) {
    return CalendarState(
      selectedDate: selectedDate != null ? normalizeDate(selectedDate) : this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      format: format ?? this.format,
    );
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    return CalendarState(
      selectedDate: normalizeDate(DateTime.now()),
      focusedDate: DateTime.now(),
      format: CalendarFormat.week, // Compact weekly view by default
    );
  }

  void selectDate(DateTime selected, DateTime focused) {
    state = state.copyWith(
      selectedDate: normalizeDate(selected),
      focusedDate: focused,
    );
  }

  void setFocusedDate(DateTime focused) {
    state = state.copyWith(focusedDate: focused);
  }

  void setFormat(CalendarFormat format) {
    state = state.copyWith(format: format);
  }

  void toggleFormat() {
    final nextFormat = state.format == CalendarFormat.week
        ? CalendarFormat.month
        : CalendarFormat.week;
    state = state.copyWith(format: nextFormat);
  }

  void jumpToToday() {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDate: normalizeDate(now),
      focusedDate: now,
    );
  }
}

final calendarNotifierProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

/// Convenience provider for the currently selected normalized date
final selectedDateProvider = Provider<DateTime>((ref) {
  return ref.watch(calendarNotifierProvider).selectedDate;
});
