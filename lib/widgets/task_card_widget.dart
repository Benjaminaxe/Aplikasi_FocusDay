import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskCardWidget extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onEdit;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color accentColor, Color containerBg, Color textAccent) = switch (task.status) {
      TaskStatus.todo => (
          AppColors.slatePrimary,
          isDark ? AppColors.slateDarkContainer : AppColors.slateLight,
          isDark ? AppColors.slateAccent : AppColors.slatePrimary,
        ),
      TaskStatus.inProgress => (
          AppColors.sandPrimary,
          isDark ? AppColors.sandDarkContainer : AppColors.sandLight,
          isDark ? AppColors.sandAccent : AppColors.sandPrimary,
        ),
      TaskStatus.done => (
          AppColors.sagePrimary,
          isDark ? AppColors.sageDarkContainer : AppColors.sageLight,
          isDark ? AppColors.sageAccent : AppColors.sagePrimary,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: Status toggle icon & Title & More Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Status Toggle Icon Button
                    GestureDetector(
                      onTap: () {
                        final nextStatus = switch (task.status) {
                          TaskStatus.todo => TaskStatus.inProgress,
                          TaskStatus.inProgress => TaskStatus.done,
                          TaskStatus.done => TaskStatus.todo,
                        };
                        ref
                            .read(taskNotifierProvider.notifier)
                            .moveTaskStatus(task.id, task.date, nextStatus);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10, top: 1),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: containerBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          task.status.icon,
                          size: 18,
                          color: accentColor,
                        ),
                      ),
                    ),

                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == TaskStatus.done
                              ? (isDark
                                  ? AppColors.textLightTertiary
                                  : AppColors.textDarkTertiary)
                              : (isDark
                                  ? AppColors.textLightPrimary
                                  : AppColors.textDarkPrimary),
                          height: 1.25,
                        ),
                      ),
                    ),

                    // Popup Menu for Edit, Move Status, Delete
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textLightTertiary
                            : AppColors.textDarkTertiary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 160),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'to_todo':
                            ref
                                .read(taskNotifierProvider.notifier)
                                .moveTaskStatus(task.id, task.date, TaskStatus.todo);
                            break;
                          case 'to_progress':
                            ref
                                .read(taskNotifierProvider.notifier)
                                .moveTaskStatus(
                                    task.id, task.date, TaskStatus.inProgress);
                            break;
                          case 'to_done':
                            ref
                                .read(taskNotifierProvider.notifier)
                                .moveTaskStatus(task.id, task.date, TaskStatus.done);
                            break;
                          case 'delete':
                            _confirmDelete(context, ref);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('Edit Tugas', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        if (task.status != TaskStatus.todo)
                          const PopupMenuItem(
                            value: 'to_todo',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_rounded,
                                    size: 16, color: AppColors.slatePrimary),
                                SizedBox(width: 8),
                                Text('Ke Harus Dikerjakan',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        if (task.status != TaskStatus.inProgress)
                          const PopupMenuItem(
                            value: 'to_progress',
                            child: Row(
                              children: [
                                Icon(Icons.timelapse_rounded,
                                    size: 16, color: AppColors.sandPrimary),
                                SizedBox(width: 8),
                                Text('Ke Sedang Dikerjakan',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        if (task.status != TaskStatus.done)
                          const PopupMenuItem(
                            value: 'to_done',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 16, color: AppColors.sagePrimary),
                                SizedBox(width: 8),
                                Text('Tandai Selesai',
                                    style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 16, color: AppColors.weekendPastel),
                              SizedBox(width: 8),
                              Text('Hapus',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.weekendPastel)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Description (if exists)
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? AppColors.textLightSecondary
                            : AppColors.textDarkSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Bottom Badges: Reminder Time & Priority
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Reminder Time Chip
                      if (task.reminderTime != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: containerBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 0.7,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: textAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatTimeOfDay(task.reminderTime!),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: textAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.slateLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.priority.icon,
                              size: 11,
                              color: isDark
                                  ? AppColors.textLightSecondary
                                  : AppColors.textDarkSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              task.priority.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textLightSecondary
                                    : AppColors.textDarkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas', style: TextStyle(fontSize: 17)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${task.title}"?',
          style: const TextStyle(fontSize: 14),
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
              ref
                  .read(taskNotifierProvider.notifier)
                  .deleteTask(task.id, task.date);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
