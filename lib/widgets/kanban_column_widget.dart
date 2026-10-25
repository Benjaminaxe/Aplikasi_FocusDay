import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_provider.dart';
import 'task_card_widget.dart';
import 'task_form_dialog.dart';

class KanbanColumnWidget extends ConsumerWidget {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final double? width;

  const KanbanColumnWidget({
    super.key,
    required this.status,
    required this.tasks,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);

    final (Color accentColor, Color bgBadge, Color headerBg) = switch (status) {
      TaskStatus.todo => (
          AppColors.slatePrimary,
          isDark ? AppColors.slateDarkContainer : AppColors.slateLight,
          isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.8)
              : AppColors.backgroundLight,
        ),
      TaskStatus.inProgress => (
          AppColors.sandPrimary,
          isDark ? AppColors.sandDarkContainer : AppColors.sandLight,
          isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.8)
              : AppColors.backgroundLight,
        ),
      TaskStatus.done => (
          AppColors.sagePrimary,
          isDark ? AppColors.sageDarkContainer : AppColors.sageLight,
          isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.8)
              : AppColors.backgroundLight,
        ),
    };

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final draggedTask = details.data;
        ref
            .read(taskNotifierProvider.notifier)
            .moveTaskStatus(draggedTask.id, selectedDate, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return RepaintBoundary(
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: isDropTarget
                  ? accentColor.withValues(alpha: 0.1)
                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDropTarget
                    ? accentColor
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isDropTarget ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Column Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: headerBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Status Dot / Icon
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Column Title
                      Expanded(
                        child: Text(
                          status.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark
                                ? AppColors.textLightPrimary
                                : AppColors.textDarkPrimary,
                          ),
                        ),
                      ),

                      // Task Count Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bgBadge,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Quick Add button for this column
                      InkWell(
                        onTap: () {
                          TaskFormDialog.show(
                            context,
                            defaultStatus: status,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tasks List with Drag and Drop
                Expanded(
                  child: tasks.isEmpty
                      ? _buildEmptyState(context, isDark, accentColor)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return LongPressDraggable<TaskModel>(
                              data: task,
                              feedback: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: (width ?? MediaQuery.of(context).size.width * 0.85) - 24,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: TaskCardWidget(
                                      task: task,
                                      onEdit: () {},
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: TaskCardWidget(
                                  task: task,
                                  onEdit: () {},
                                ),
                              ),
                              child: TaskCardWidget(
                                task: task,
                                onEdit: () {
                                  TaskFormDialog.show(
                                    context,
                                    existingTask: task,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: 32,
              color: isDark
                  ? AppColors.textLightTertiary.withValues(alpha: 0.3)
                  : AppColors.textDarkTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada tugas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textLightSecondary
                    : AppColors.textDarkSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tarik tugas ke sini atau tekan tombol + di atas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.textLightTertiary
                    : AppColors.textDarkTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
