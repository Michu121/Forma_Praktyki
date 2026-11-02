import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'note_editor.dart';
import 'training_session_sheet.dart';
import 'workout_builder_sheet.dart';
import 'workout_models.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({
    required this.date,
    required this.workout,
    required this.note,
    required this.templates,
    required this.isTodayCompleted,
    required this.onCreateTemplate,
    required this.onSaveNote,
    required this.onSaveWorkoutNote,
    required this.onCompleteWorkout,
    super.key,
  });

  final DateTime date;
  final WorkoutPlan workout;
  final String note;
  final List<WorkoutPlan> templates;
  final bool isTodayCompleted;
  final ValueChanged<WorkoutPlan> onCreateTemplate;
  final ValueChanged<String> onSaveNote;
  final ValueChanged<String> onSaveWorkoutNote;
  final VoidCallback onCompleteWorkout;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 27),
        Text(
          'Twój plan',
          style: TextStyle(
            color: colors.foreground,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Schemat przypisany do tego dnia',
          style: TextStyle(color: colors.muted),
        ),
        const SizedBox(height: 22),
        _PlanProgressCard(workout: workout),
        const SizedBox(height: 24),
        SectionTitle(
          '${_capitalize(polishWeekdays[date.weekday - 1])} • ${workout.name}',
          trailing: '${workout.estimatedMinutes} min',
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < workout.exercises.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: ExerciseTile(
              title: workout.exercises[index].name,
              subtitle: workout.exercises[index].planSummary,
              icon: workout.exercises[index].icon,
              number: index + 1,
            ),
          ),
        if (workout.exercises.isEmpty)
          Text(
            'Dodaj ćwiczenia, aby zbudować trening.',
            style: TextStyle(color: colors.muted),
          ),
        const SizedBox(height: 8),
        WorkoutCard(
          workout: workout,
          completed: isTodayCompleted,
          onStart: () => _startWorkout(context),
          onOpenPlan: () async {
            final updated = await showNoteEditor(
              context,
              initialText: workout.note,
            );
            if (updated != null) onSaveWorkoutNote(updated);
          },
        ),
        const SizedBox(height: 16),
        SectionTitle('Notatka do treningu'),
        const SizedBox(height: 8),
        NoteCard(
          note: workout.note,
          onTap: () async {
            final updated = await showNoteEditor(
              context,
              initialText: workout.note,
            );
            if (updated != null) onSaveWorkoutNote(updated);
          },
        ),
        const SizedBox(height: 16),
        SectionTitle('Notatka do dnia'),
        const SizedBox(height: 8),
        NoteCard(
          note: note,
          onTap: () async {
            final updated = await showNoteEditor(context, initialText: note);
            if (updated != null) onSaveNote(updated);
          },
        ),
        const SizedBox(height: 24),
        SectionTitle('Moje schematy'),
        const SizedBox(height: 10),
        for (final template in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TemplateCard(workout: template),
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final template = await showWorkoutBuilder(context);
            if (template != null) onCreateTemplate(template);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Utwórz nowy schemat'),
        ),
      ],
    );
  }

  void _startWorkout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TrainingSessionSheet(
        workout: workout,
        onComplete: () {
          Navigator.of(sheetContext).pop();
          onCompleteWorkout();
        },
      ),
    );
  }

  String _capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.workout});

  final WorkoutPlan workout;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return ListTile(
      tileColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Icon(workout.type.icon, color: colors.accent),
      title: Text(workout.name),
      subtitle: Text('${workout.exercises.length} ćwiczeń • schemat'),
    );
  }
}

class _PlanProgressCard extends StatelessWidget {
  const _PlanProgressCard({required this.workout});

  final WorkoutPlan workout;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(workout.type.icon, color: colors.accent, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: TextStyle(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout.exercises.length} ćwiczeń • przerwa ${workout.restSeconds} s',
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.tune_rounded, color: colors.accent),
        ],
      ),
    );
  }
}
