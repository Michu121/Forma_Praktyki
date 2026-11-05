import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'note_editor.dart';
import 'workout_models.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({
    required this.date,
    required this.workout,
    required this.note,
    required this.templates,
    required this.onSaveNote,
    required this.onSaveWorkoutNote,
    super.key,
  });

  final DateTime date;
  final WorkoutPlan workout;
  final String note;
  final List<WorkoutPlan> templates;
  final ValueChanged<String> onSaveNote;
  final ValueChanged<String> onSaveWorkoutNote;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 27),
        const AppPageTitle('Plan treningowy'),
        const SizedBox(height: 6),
        Text(
          'Ćwiczenia i zapisane schematy',
          style: TextStyle(color: colors.muted),
        ),
        const SizedBox(height: 22),
        SectionTitle(
          '${_capitalize(polishWeekdays[date.weekday - 1])} • ${workout.name}',
          trailing: '${workout.exercises.length} ćwiczeń',
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
        const SectionTitle('Moje schematy'),
        const SizedBox(height: 4),
        Text(
          'Schematy możesz tworzyć i edytować w Ustawieniach.',
          style: TextStyle(color: colors.muted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        for (final template in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TemplateCard(workout: template),
          ),
      ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appCardRadius),
      ),
      leading: Icon(workout.type.icon, color: colors.accent),
      title: Text(workout.name),
      subtitle: Text('${workout.exercises.length} ćwiczeń • schemat'),
    );
  }
}
