import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'kanban_column_widget.dart';

enum KanbanViewMode {
  tabs,
  board,
}

class KanbanBoardWidget extends ConsumerStatefulWidget {
  const KanbanBoardWidget({super.key});

  @override
  ConsumerState<KanbanBoardWidget> createState() => _KanbanBoardWidgetState();
}

class _KanbanBoardWidgetState extends ConsumerState<KanbanBoardWidget>
    with SingleTickerProviderStateMixin {
  KanbanViewMode _viewMode = KanbanViewMode.tabs;
  int _selectedTabIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todoTasks = ref.watch(todoTasksProvider);
    final inProgressTasks = ref.watch(inProgressTasksProvider);
    final doneTasks = ref.watch(doneTasksProvider);

    final totalCount = todoTasks.length + inProgressTasks.length + doneTasks.length;
    final progress = totalCount > 0 ? (doneTasks.length / totalCount) : 0.0;

    return Column(
      children: [
        // Top Bar: Progress Indicator & View Mode Switcher
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Row(
            children: [
              // Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kemajuan Harian',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textLightSecondary
                                : AppColors.textDarkSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$totalCount Tugas • ${(progress * 100).toInt()}% Selesai',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.sageAccent
                                : AppColors.sagePrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.cardDark
                            : AppColors.slateLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.sageAccent : AppColors.sagePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // View Mode Toggle (Tabs vs Board)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.slateLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeIcon(
                      icon: Icons.view_carousel_rounded,
                      tooltip: 'Tampilan Tab',
                      isActive: _viewMode == KanbanViewMode.tabs,
                      onTap: () {
                        setState(() {
                          _viewMode = KanbanViewMode.tabs;
                        });
                      },
                      isDark: isDark,
                    ),
                    _buildModeIcon(
                      icon: Icons.view_column_rounded,
                      tooltip: 'Tampilan Papan Penuh',
                      isActive: _viewMode == KanbanViewMode.board,
                      onTap: () {
                        setState(() {
                          _viewMode = KanbanViewMode.board;
                        });
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Tabs Selector (Visible in Tabs View Mode)
        if (_viewMode == KanbanViewMode.tabs) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabPill(
                  title: 'Harus Dikerjakan',
                  count: todoTasks.length,
                  index: 0,
                  accentColor: AppColors.slatePrimary,
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildTabPill(
                  title: 'Sedang Berjalan',
                  count: inProgressTasks.length,
                  index: 1,
                  accentColor: AppColors.sandPrimary,
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildTabPill(
                  title: 'Telah Selesai',
                  count: doneTasks.length,
                  index: 2,
                  accentColor: AppColors.sagePrimary,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Column Content Area
        Expanded(
          child: _viewMode == KanbanViewMode.tabs
              ? PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: KanbanColumnWidget(
                        status: TaskStatus.todo,
                        tasks: todoTasks,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: KanbanColumnWidget(
                        status: TaskStatus.inProgress,
                        tasks: inProgressTasks,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: KanbanColumnWidget(
                        status: TaskStatus.done,
                        tasks: doneTasks,
                      ),
                    ),
                  ],
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    KanbanColumnWidget(
                      status: TaskStatus.todo,
                      tasks: todoTasks,
                      width: 290,
                    ),
                    const SizedBox(width: 12),
                    KanbanColumnWidget(
                      status: TaskStatus.inProgress,
                      tasks: inProgressTasks,
                      width: 290,
                    ),
                    const SizedBox(width: 12),
                    KanbanColumnWidget(
                      status: TaskStatus.done,
                      tasks: doneTasks,
                      width: 290,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildModeIcon({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.cardDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (isDark ? AppColors.sageAccent : AppColors.sagePrimary)
                : (isDark
                    ? AppColors.textLightTertiary
                    : AppColors.textDarkTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required int count,
    required int index,
    required Color accentColor,
    required bool isDark,
  }) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.surfaceDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 1.5 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title.split(' ').first,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : (isDark
                          ? AppColors.textLightSecondary
                          : AppColors.textDarkSecondary),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : (isDark ? AppColors.cardDark : AppColors.slateLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? accentColor
                        : (isDark
                            ? AppColors.textLightTertiary
                            : AppColors.textDarkTertiary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
