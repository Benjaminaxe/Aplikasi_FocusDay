import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/kanban_board_widget.dart';
import '../widgets/task_form_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.sageDarkContainer
                    : AppColors.sageLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: isDark ? AppColors.sageAccent : AppColors.sagePrimary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'FocusDay',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textLightPrimary
                            : AppColors.textDarkPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.slateLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '120Hz AMOLED',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.sageAccent
                              : AppColors.sagePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  getRelativeDateLabel(selectedDate) == 'Hari Ini'
                      ? 'Fokus Hari Ini • ${formatShortDate(selectedDate)}'
                      : '${getRelativeDateLabel(selectedDate)} • ${formatShortDate(selectedDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textLightTertiary
                        : AppColors.textDarkTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Toggle Button (Light Soft <-> AMOLED Dark)
          IconButton(
            tooltip: 'Ganti Tema',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 20,
              color: isDark
                  ? AppColors.sandAccent
                  : AppColors.textDarkSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Integration at Top (Weekly/Monthly Expandable)
            const CalendarHeaderWidget(),

            // Selected Date Context Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 15,
                    color: isDark
                        ? AppColors.sageAccent
                        : AppColors.sagePrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Papan Jadwal: ${formatFullDateIndonesian(selectedDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textLightPrimary
                          : AppColors.textDarkPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Quick button to clear all completed for this date if any
                  Consumer(
                    builder: (context, ref, child) {
                      final doneTasks = ref.watch(doneTasksProvider);
                      if (doneTasks.isEmpty) return const SizedBox.shrink();

                      return InkWell(
                        onTap: () {
                          _confirmClearDone(context, ref, selectedDate);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          child: Text(
                            'Bersihkan Selesai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.weekendPastel,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Kanban Board (Harus Dikerjakan, Sedang Dikerjakan, Telah Selesai)
            const Expanded(
              child: KanbanBoardWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          TaskFormDialog.show(context);
        },
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text(
          'Tambah Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  void _confirmClearDone(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bersihkan Tugas Selesai',
            style: TextStyle(fontSize: 16)),
        content: const Text(
          'Hapus semua tugas yang telah berstatus selesai pada tanggal ini?',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.weekendPastel,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskNotifierProvider.notifier).clearCompleted(date);
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }
}
