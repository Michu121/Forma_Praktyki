import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'note_editor.dart';
import 'rest_notification_service.dart';
import 'training_session_sheet.dart';
import 'workout_models.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    required this.selectedDate,
    required this.completedWorkouts,
    required this.workouts,
    required this.templates,
    required this.dayNote,
    required this.onSelectDate,
    required this.onSaveWorkout,
    required this.onSaveDayNote,
    required this.onSaveWorkoutNote,
    required this.onCompleteWorkout,
    required this.restNotifications,
    super.key,
  });

  final DateTime selectedDate;
  final Set<DateTime> completedWorkouts;
  final Map<DateTime, WorkoutPlan> workouts;
  final List<WorkoutPlan> templates;
  final String dayNote;
  final ValueChanged<DateTime> onSelectDate;
  final void Function(DateTime date, WorkoutPlan plan) onSaveWorkout;
  final void Function(DateTime date, String note) onSaveDayNote;
  final void Function(DateTime date, String note) onSaveWorkoutNote;
  final ValueChanged<DateTime> onCompleteWorkout;
  final RestNotificationController restNotifications;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final selectedDate = dateOnly(widget.selectedDate);
    final isCompleted = _isCompleted(selectedDate);
    final workout = _workoutOn(selectedDate);
    final colors = GymColors.of(context);

    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 27),
        const AppPageTitle('Kalendarz'),
        const SizedBox(height: 6),
        Text('Twój rytm, Twoje tempo.', style: TextStyle(color: colors.muted)),
        const SizedBox(height: 22),
        _monthCard(today, selectedDate),
        const SizedBox(height: 24),
        SectionTitle(
          fullDateLabel(selectedDate),
          trailing: isCompleted ? 'Trening wykonany' : null,
        ),
        const SizedBox(height: 12),
        if (workout != null)
          WorkoutCard(
            workout: workout,
            isCalendar: true,
            completed: isCompleted,
            onStart: () => _startWorkout(context, selectedDate, workout),
            onOpenPlan: () => _editWorkoutNote(context, selectedDate, workout),
          )
        else
          _EmptyWorkoutCard(
            onAdd: () => _scheduleWorkout(context, selectedDate),
          ),
        if (workout != null) ...[
          const SizedBox(height: 12),
          SectionTitle('Notatka do treningu'),
          const SizedBox(height: 8),
          NoteCard(
            note: workout.note,
            onTap: () => _editWorkoutNote(context, selectedDate, workout),
          ),
        ],
        const SizedBox(height: 20),
        SectionTitle('Notatka do dnia'),
        const SizedBox(height: 8),
        NoteCard(
          note: widget.dayNote,
          onTap: () => _editDayNote(context, selectedDate),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Oznaczenia'),
        const SizedBox(height: 10),
        const _CalendarLegend(),
      ],
    );
  }

  Widget _monthCard(DateTime today, DateTime selectedDate) {
    final colors = GymColors.of(context);
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leadingDays = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  monthLabel(_visibleMonth),
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: shortWeekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: List.generate(7, (weekday) {
                  final dayNumber = week * 7 + weekday - leadingDays + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 46));
                  }
                  final date = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    dayNumber,
                  );
                  return Expanded(
                    child: _DayCell(
                      date: date,
                      isToday: sameDate(date, today),
                      isSelected: sameDate(date, selectedDate),
                      isCompleted: _isCompleted(date),
                      hasPlannedWorkout: _workoutOn(date) != null,
                      onTap: () => widget.onSelectDate(date),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isCompleted(DateTime date) =>
      widget.completedWorkouts.any((completed) => sameDate(completed, date));

  WorkoutPlan? _workoutOn(DateTime date) {
    for (final entry in widget.workouts.entries) {
      if (sameDate(entry.key, date)) return entry.value;
    }
    return null;
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
    widget.onSelectDate(_visibleMonth);
  }

  Future<void> _scheduleWorkout(BuildContext context, DateTime date) async {
    final selected = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const ListTile(
              title: Text('Wybierz schemat'),
              subtitle: Text('Zaplanuj trening na wybrany dzień.'),
            ),
            for (final template in widget.templates)
              ListTile(
                leading: Icon(template.type.icon),
                title: Text(template.name),
                subtitle: Text('${template.exercises.length} ćwiczeń'),
                onTap: () => Navigator.pop(sheetContext, template),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (selected is WorkoutPlan) {
      widget.onSaveWorkout(date, selected);
    }
  }

  Future<void> _editDayNote(BuildContext context, DateTime date) async {
    final note = await showNoteEditor(context, initialText: widget.dayNote);
    if (note != null) widget.onSaveDayNote(date, note);
  }

  Future<void> _editWorkoutNote(
    BuildContext context,
    DateTime date,
    WorkoutPlan workout,
  ) async {
    final note = await showNoteEditor(context, initialText: workout.note);
    if (note != null) widget.onSaveWorkoutNote(date, note);
  }

  void _startWorkout(BuildContext context, DateTime date, WorkoutPlan workout) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TrainingSessionSheet(
        workout: workout,
        restNotifications: widget.restNotifications,
        onComplete: () {
          Navigator.of(sheetContext).pop();
          widget.onCompleteWorkout(date);
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCompleted,
    required this.hasPlannedWorkout,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isCompleted;
  final bool hasPlannedWorkout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final background = isSelected
        ? colors.accent
        : (isCompleted
              ? colors.accent.withValues(alpha: 0.3)
              : Colors.transparent);
    final foreground = isSelected ? colors.background : colors.foreground;

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${fullDateLabel(date)}${isCompleted ? ', trening wykonany' : (hasPlannedWorkout ? ', zaplanowany trening' : '')}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 33,
                  height: 33,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(11),
                    border: isToday && !isSelected
                        ? Border.all(color: colors.accent, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: foreground,
                      fontWeight: isToday || isSelected || isCompleted
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isCompleted || hasPlannedWorkout)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.background
                          : (isCompleted
                                ? colors.accent
                                : const Color(0xFFF0B86A)),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWorkoutCard extends StatelessWidget {
  const _EmptyWorkoutCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: colors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Wybierz zapisany schemat treningu.',
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Row(
      children: [
        _LegendItem(color: colors.accent, label: 'Wykonany'),
        const SizedBox(width: 17),
        const _LegendItem(color: Color(0xFFF0B86A), label: 'Zaplanowany'),
        const SizedBox(width: 17),
        _LegendItem(color: colors.muted, label: 'Dzisiaj'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: GymColors.of(context).muted, fontSize: 10),
          ),
        ),
      ],
    ),
  );
}
