import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_provider.dart';

class CalendarHeaderWidget extends ConsumerWidget {
  const CalendarHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
    final eventLoader = ref.watch(calendarEventsLoaderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isWeekFormat = calendarState.format == CalendarFormat.week;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Calm Minimalist Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
              child: Row(
                children: [
                  // Month & Year Title
                  Text(
                    _formatHeaderMonth(calendarState.focusedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textLightPrimary
                          : AppColors.textDarkPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),

                  // "Hari Ini" (Jump to Today) Button
                  TextButton.icon(
                    onPressed: () {
                      calendarNotifier.jumpToToday();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: isDark
                          ? AppColors.cardDark
                          : AppColors.slateLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      Icons.today_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.sageAccent
                          : AppColors.sagePrimary,
                    ),
                    label: Text(
                      'Hari Ini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.sageAccent
                            : AppColors.sagePrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Format Toggle (Minggu / Bulan)
                  InkWell(
                    onTap: () {
                      calendarNotifier.toggleFormat();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.slateLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isWeekFormat
                                ? Icons.calendar_view_week_rounded
                                : Icons.calendar_month_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.textLightSecondary
                                : AppColors.textDarkSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isWeekFormat ? 'Mingguan' : 'Bulanan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textLightSecondary
                                  : AppColors.textDarkSecondary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            isWeekFormat
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.textLightTertiary
                                : AppColors.textDarkTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TableCalendar with custom soft styling and 120Hz smooth scrolling
            TableCalendar<TaskModel>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: calendarState.focusedDate,
              calendarFormat: calendarState.format,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Bulanan',
                CalendarFormat.week: 'Mingguan',
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false, // We use custom header above
              rowHeight: 46,
              daysOfWeekHeight: 26,
              pageAnimationCurve: Curves.easeOutCubic,
              pageAnimationDuration: const Duration(milliseconds: 250),
              selectedDayPredicate: (day) =>
                  isSameCalendarDay(calendarState.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                calendarNotifier.selectDate(selectedDay, focusedDay);
              },
              onPageChanged: (focusedDay) {
                calendarNotifier.setFocusedDate(focusedDay);
              },
              onFormatChanged: (format) {
                calendarNotifier.setFormat(format);
              },
              eventLoader: eventLoader,

              // Days of week styling
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textLightTertiary
                      : AppColors.textDarkTertiary,
                ),
                weekendStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.weekendPastel,
                ),
                dowTextFormatter: (date, locale) {
                  const days = ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
                  return days[date.weekday - 1];
                },
              ),

              // Calendar custom cell builders
              calendarBuilders: CalendarBuilders(
                // Selected Day: Soft Sage Green circle
                selectedBuilder: (context, date, focusedDay) {
                  return _buildDayCell(
                    date: date,
                    isSelected: true,
                    isToday: isSameCalendarDay(date, DateTime.now()),
                    isWeekend: date.weekday == 6 || date.weekday == 7,
                    isDark: isDark,
                  );
                },

                // Today cell (if not selected)
                todayBuilder: (context, date, focusedDay) {
                  return _buildDayCell(
                    date: date,
                    isSelected: false,
                    isToday: true,
                    isWeekend: date.weekday == 6 || date.weekday == 7,
                    isDark: isDark,
                  );
                },

                // Default regular day
                defaultBuilder: (context, date, focusedDay) {
                  return _buildDayCell(
                    date: date,
                    isSelected: false,
                    isToday: false,
                    isWeekend: false,
                    isDark: isDark,
                  );
                },

                // Weekend day: Muted red/pink pastel
                holidayBuilder: (context, date, focusedDay) {
                  return _buildDayCell(
                    date: date,
                    isSelected: false,
                    isToday: false,
                    isWeekend: true,
                    isDark: isDark,
                  );
                },

                // Outside month days
                outsideBuilder: (context, date, events) {
                  return Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textLightTertiary.withValues(alpha: 0.3)
                            : AppColors.textDarkTertiary.withValues(alpha: 0.35),
                      ),
                    ),
                  );
                },

                // Soft visual marker: elegant small sage green or sand dots
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox.shrink();

                  // Up to 3 soft dots
                  final count = events.length.clamp(1, 3);
                  final hasDone = events.any((e) => e.status == TaskStatus.done);
                  final hasInProgress = events.any((e) => e.status == TaskStatus.inProgress);

                  Color dotColor = AppColors.slatePrimary;
                  if (hasDone && !hasInProgress) {
                    dotColor = AppColors.sageDot;
                  } else if (hasInProgress) {
                    dotColor = AppColors.sandPrimary;
                  }

                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(count, (index) {
                        return Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor.withValues(alpha: 0.85),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required bool isWeekend,
    required bool isDark,
  }) {
    Color textColor;
    BoxDecoration? decoration;

    if (isSelected) {
      textColor = Colors.white;
      decoration = BoxDecoration(
        color: isDark ? AppColors.sageAccent : AppColors.sagePrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.sageAccent : AppColors.sagePrimary)
                .withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (isToday) {
      textColor = isDark ? AppColors.sageAccent : AppColors.sagePrimary;
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: (isDark ? AppColors.sageAccent : AppColors.sagePrimary)
              .withValues(alpha: 0.8),
          width: 1.5,
        ),
        color: (isDark ? AppColors.sageAccent : AppColors.sagePrimary)
            .withValues(alpha: 0.08),
      );
    } else if (isWeekend) {
      textColor = AppColors.weekendPastel;
    } else {
      textColor = isDark
          ? AppColors.textLightPrimary
          : AppColors.textDarkPrimary;
    }

    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  String _formatHeaderMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
