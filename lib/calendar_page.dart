import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    required this.selectedDate,
    required this.completedWorkouts,
    required this.onSelectDate,
    required this.onCompleteWorkout,
    super.key,
  });

  final DateTime selectedDate;
  final Set<DateTime> completedWorkouts;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onCompleteWorkout;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final selectedDate = dateOnly(widget.selectedDate);
    final isSelectedCompleted = _isCompleted(selectedDate);

    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 27),
        const Text(
          'Kalendarz',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Twój rytm, Twoje tempo.',
          style: TextStyle(color: appMuted),
        ),
        const SizedBox(height: 22),
        _monthCard(today, selectedDate),
        const SizedBox(height: 24),
        SectionTitle(
          fullDateLabel(selectedDate),
          trailing: isSelectedCompleted ? 'Trening wykonany' : 'Plan treningowy',
        ),
        const SizedBox(height: 12),
        WorkoutCard(
          isCalendar: true,
          completed: isSelectedCompleted,
          onStart: () => _startWorkout(context, selectedDate),
          onOpenPlan: () => _startWorkout(context, selectedDate),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Oznaczenia'),
        const SizedBox(height: 10),
        const _CalendarLegend(),
        const SizedBox(height: 20),
        WeeklyActivityChart(completedWorkouts: widget.completedWorkouts),
      ],
    );
  }

  Widget _monthCard(DateTime today, DateTime selectedDate) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leadingDays = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  monthLabel(_visibleMonth),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
                        style: const TextStyle(
                          color: appMuted,
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
                  final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
                  return Expanded(
                    child: _DayCell(
                      date: date,
                      isToday: sameDate(date, today),
                      isSelected: sameDate(date, selectedDate),
                      isCompleted: _isCompleted(date),
                      hasPlannedWorkout: _hasPlannedWorkout(date),
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

  bool _hasPlannedWorkout(DateTime date) =>
      date.weekday == DateTime.monday ||
      date.weekday == DateTime.wednesday ||
      date.weekday == DateTime.friday;

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    });
    widget.onSelectDate(_visibleMonth);
  }

  void _startWorkout(BuildContext context, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TrainingSessionSheet(
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
    final background = isSelected
        ? appLime
        : (isCompleted ? const Color(0xFF3B542A) : Colors.transparent);
    final foreground = isSelected ? appBackground : Colors.white;

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
                        ? Border.all(color: appLime, width: 1.5)
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
                          ? appBackground
                          : (isCompleted ? appLime : const Color(0xFFF0B86A)),
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

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendItem(color: appLime, label: 'Wykonany'),
        SizedBox(width: 17),
        _LegendItem(color: Color(0xFFF0B86A), label: 'Zaplanowany'),
        SizedBox(width: 17),
        _LegendItem(color: Colors.white70, label: 'Dzisiaj'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              style: const TextStyle(color: appMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
