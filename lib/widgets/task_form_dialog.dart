import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/services/speech_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import '../providers/calendar_provider.dart';
import '../providers/task_provider.dart';

class TaskFormDialog extends ConsumerStatefulWidget {
  final TaskModel? existingTask;
  final TaskStatus? defaultStatus;

  const TaskFormDialog({
    super.key,
    this.existingTask,
    this.defaultStatus,
  });

  static Future<void> show(
    BuildContext context, {
    TaskModel? existingTask,
    TaskStatus? defaultStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormDialog(
        existingTask: existingTask,
        defaultStatus: defaultStatus,
      ),
    );
  }

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  TimeOfDay? _selectedReminder;

  bool _isListening = false;
  String _listeningStatus = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedStatus =
        widget.defaultStatus ?? task?.status ?? TaskStatus.todo;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedDate =
        task?.date ?? ref.read(calendarNotifierProvider).selectedDate;
    _selectedReminder = task?.reminderTime;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pulseController.dispose();
    SpeechService.instance.stopListening();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await SpeechService.instance.stopListening();
      if (mounted) {
        setState(() {
          _isListening = false;
          _listeningStatus = '';
        });
      }
      return;
    }

    setState(() {
      _listeningStatus = 'Menghubungkan mikrofon...';
    });

    final available = await SpeechService.instance.initialize(
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _listeningStatus = 'Mikrofon: ${error.errorMsg}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catatan Suara: ${error.errorMsg}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _listeningStatus = 'Status: $status';
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
            }
          });
        }
      },
    );

    if (!available) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _listeningStatus = 'Pengenalan suara tidak aktif pada perangkat ini.';
        });
        // Friendly dialog offering voice demo text
        _showVoiceUnavailableHelper();
      }
      return;
    }

    setState(() {
      _isListening = true;
      _listeningStatus = 'Mendengarkan... Silakan bicara';
    });

    final currentTitle = _titleController.text;

    await SpeechService.instance.startListening(
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          if (currentTitle.isEmpty) {
            _titleController.text = words;
          } else {
            _titleController.text = '$currentTitle $words';
          }
        });
        if (isFinal) {
          setState(() {
            _isListening = false;
            _listeningStatus = 'Selesai didikte';
          });
        }
      },
    );
  }

  void _showVoiceUnavailableHelper() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic_none_rounded, color: AppColors.sandPrimary),
            SizedBox(width: 8),
            Text('Input Suara', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text(
          'Fitur speech_to_text terintegrasi dan siap digunakan di perangkat mobile (POCO F7 / Android). Jika mikrofon desktop/browser sedang tidak aktif, Anda dapat mencoba template suara cepat di bawah ini.',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _titleController.text = 'Siapkan materi presentasi proyek';
                _descController.text =
                    'Didikte lewat asisten suara FocusDay';
                _selectedReminder = const TimeOfDay(hour: 15, minute: 30);
              });
            },
            child: const Text('Isi Contoh Suara'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminder ?? now,
      helpText: 'PILIH WAKTU PENGINGAT TUGAS',
      confirmText: 'SIMPAN',
      cancelText: 'BATAL',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.sageAccent,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.textLightPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.sagePrimary,
                    surface: AppColors.surfaceLight,
                    onSurface: AppColors.textDarkPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedReminder = picked;
      });
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tugas tidak boleh kosong.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final taskNotifier = ref.read(taskNotifierProvider.notifier);

    if (widget.existingTask != null) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        description: _descController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        date: _selectedDate,
        reminderTime: _selectedReminder,
        clearReminder: _selectedReminder == null,
      );
      taskNotifier.updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: _descController.text.trim(),
        date: _selectedDate,
        status: _selectedStatus,
        priority: _selectedPriority,
        reminderTime: _selectedReminder,
      );
      taskNotifier.addTask(newTask);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title & Voice Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingTask != null ? 'Edit Tugas' : 'Tambah Tugas Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textLightPrimary
                              : AppColors.textDarkPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Untuk ${formatFullDateIndonesian(_selectedDate)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textLightTertiary
                              : AppColors.textDarkTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Animated Speech To Text Button
                GestureDetector(
                  onTap: _toggleVoiceInput,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? AppColors.weekendPastel
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.slateLight),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isListening
                                  ? AppColors.weekendPastel
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                size: 18,
                                color: _isListening
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.sageAccent
                                        : AppColors.sagePrimary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isListening ? 'Mendengarkan' : 'Input Suara',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isListening
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.textLightPrimary
                                          : AppColors.textDarkPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            if (_listeningStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _listeningStatus,
                style: TextStyle(
                  fontSize: 11.5,
                  color: _isListening
                      ? AppColors.sandPrimary
                      : (isDark
                          ? AppColors.textLightTertiary
                          : AppColors.textDarkTertiary),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              autofocus: widget.existingTask == null,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textLightPrimary
                    : AppColors.textDarkPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Nama rencana atau tugas...',
                prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Description Field
            TextField(
              controller: _descController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark
                    ? AppColors.textLightPrimary
                    : AppColors.textDarkPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Deskripsi / catatan tambahan (opsional)...',
                prefixIcon: Icon(Icons.notes_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 16),

            // Status Selector (Kanban Columns)
            Text(
              'Kolom Status Kanban:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textLightSecondary
                    : AppColors.textDarkSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: TaskStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                final (Color activeColor, Color activeBg) = switch (status) {
                  TaskStatus.todo => (
                      AppColors.slatePrimary,
                      isDark
                          ? AppColors.slateDarkContainer
                          : AppColors.slateLight
                    ),
                  TaskStatus.inProgress => (
                      AppColors.sandPrimary,
                      isDark
                          ? AppColors.sandDarkContainer
                          : AppColors.sandLight
                    ),
                  TaskStatus.done => (
                      AppColors.sagePrimary,
                      isDark ? AppColors.sageDarkContainer : AppColors.sageLight
                    ),
                };

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activeBg
                            : (isDark
                                ? AppColors.cardDark
                                : AppColors.backgroundLight),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? activeColor
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status.icon,
                            size: 16,
                            color: isSelected
                                ? activeColor
                                : (isDark
                                    ? AppColors.textLightTertiary
                                    : AppColors.textDarkTertiary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.shortTitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? activeColor
                                  : (isDark
                                      ? AppColors.textLightSecondary
                                      : AppColors.textDarkSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Reminder Time & Priority Row
            Row(
              children: [
                // Reminder Time Picker
                Expanded(
                  child: InkWell(
                    onTap: _pickReminderTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.slateLight.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            size: 16,
                            color: _selectedReminder != null
                                ? (isDark
                                    ? AppColors.sandAccent
                                    : AppColors.sandPrimary)
                                : (isDark
                                    ? AppColors.textLightTertiary
                                    : AppColors.textDarkTertiary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedReminder != null
                                  ? formatTimeOfDay(_selectedReminder!)
                                  : 'Atur Pengingat',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: _selectedReminder != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedReminder != null
                                    ? (isDark
                                        ? AppColors.textLightPrimary
                                        : AppColors.textDarkPrimary)
                                    : (isDark
                                        ? AppColors.textLightTertiary
                                        : AppColors.textDarkTertiary),
                              ),
                            ),
                          ),
                          if (_selectedReminder != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedReminder = null;
                                });
                              },
                              child: const Icon(Icons.close_rounded, size: 14),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Priority Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.slateLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskPriority>(
                        value: _selectedPriority,
                        isExpanded: true,
                        dropdownColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(priority.icon, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  priority.label,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPriority = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Submit Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textLightSecondary
                            : AppColors.textDarkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _saveTask,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.sageAccent
                          : AppColors.sagePrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.existingTask != null
                          ? 'Perbarui Tugas'
                          : 'Simpan Tugas',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.backgroundDark : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
