import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_settings.dart';
import 'bmi_calculator_page.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'note_editor.dart';
import 'settings_page.dart';
import 'welcome_message.dart';
import 'workout_models.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.points,
    required this.completedWorkouts,
    required this.note,
    required this.settings,
    required this.settingsError,
    required this.templates,
    required this.defaultRestSeconds,
    required this.onCreateTemplate,
    required this.onThemeChanged,
    required this.onPaletteChanged,
    required this.onRestChanged,
    required this.onProfileNameChanged,
    required this.onProfileStatsChanged,
    required this.onWorkoutReminderScheduleChanged,
    required this.onWeeklyWorkoutGoalChanged,
    required this.onSaveNote,
    super.key,
  });

  final int points;
  final Set<DateTime> completedWorkouts;
  final String note;
  final AppSettings settings;
  final String? settingsError;
  final List<WorkoutPlan> templates;
  final int defaultRestSeconds;
  final ValueChanged<WorkoutPlan> onCreateTemplate;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<GymPalette> onPaletteChanged;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<bool> onProfileNameChanged;
  final ValueChanged<bool> onProfileStatsChanged;
  final ValueChanged<AppSettings> onWorkoutReminderScheduleChanged;
  final ValueChanged<int> onWeeklyWorkoutGoalChanged;
  final ValueChanged<String> onSaveNote;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final hours = completedWorkouts.length * 0.9;
    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 29),
        Center(
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: 14),
              if (settings.showProfileName)
                Text(
                  defaultProfileName,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                settings.showProfileStats
                    ? 'Ranga ${rankName(points)} • $points pkt'
                    : 'Twój profil treningowy',
                style: TextStyle(color: colors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        if (settings.showProfileStats)
          Row(
            children: [
              _ProfileStat(
                value: '${completedWorkouts.length}',
                label: 'treningi',
              ),
              const SizedBox(width: 10),
              _ProfileStat(
                value: '${hours.toStringAsFixed(1)} h',
                label: 'na siłowni',
              ),
              const SizedBox(width: 10),
              _ProfileStat(value: '$points pkt', label: 'punkty'),
            ],
          ),
        const SizedBox(height: 25),
        const SectionTitle('Twój notes'),
        const SizedBox(height: 12),
        NoteCard(
          note: note,
          onTap: () async {
            final updated = await showNoteEditor(context, initialText: note);
            if (updated != null) onSaveNote(updated);
          },
        ),
        const SizedBox(height: 25),
        const SectionTitle('Twoje konto'),
        const SizedBox(height: 12),
        ProfileOption(
          icon: Icons.edit_note_rounded,
          title: 'Notatki treningowe',
          subtitle: note.isEmpty
              ? 'Napisz pierwszą notatkę'
              : 'Edytuj zapisane notatki',
          onTap: () async {
            final updated = await showNoteEditor(context, initialText: note);
            if (updated != null) onSaveNote(updated);
          },
        ),
        ProfileOption(
          icon: Icons.settings_outlined,
          title: 'Ustawienia',
          subtitle: 'Ogólne, prywatność i informacje',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SettingsPage(
                settings: settings,
                settingsError: settingsError,
                templates: templates,
                defaultRestSeconds: defaultRestSeconds,
                onCreateTemplate: onCreateTemplate,
                onThemeChanged: onThemeChanged,
                onPaletteChanged: onPaletteChanged,
                onRestChanged: onRestChanged,
                onProfileNameChanged: onProfileNameChanged,
                onProfileStatsChanged: onProfileStatsChanged,
                onWorkoutReminderScheduleChanged:
                    onWorkoutReminderScheduleChanged,
              ),
            ),
          ),
        ),
        ProfileOption(
          icon: Icons.track_changes_rounded,
          title: 'Cele treningowe',
          subtitle:
              '${workoutsCompletedThisWeek(completedWorkouts, DateTime.now())}'
              ' z ${settings.weeklyWorkoutGoal} treningów w tym tygodniu',
          onTap: () => _editWeeklyWorkoutGoal(context),
        ),
        ProfileOption(
          icon: Icons.monitor_weight_outlined,
          title: 'Kalkulator BMI',
          subtitle: 'Oblicz orientacyjny wskaźnik masy ciała',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BmiCalculatorPage()),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Future<void> _editWeeklyWorkoutGoal(BuildContext context) async {
    final updatedGoal = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _WeeklyWorkoutGoalDialog(
        currentGoal: settings.weeklyWorkoutGoal,
        completed: workoutsCompletedThisWeek(completedWorkouts, DateTime.now()),
      ),
    );
    if (updatedGoal != null) onWeeklyWorkoutGoalChanged(updatedGoal);
  }
}

class _WeeklyWorkoutGoalDialog extends StatefulWidget {
  const _WeeklyWorkoutGoalDialog({
    required this.currentGoal,
    required this.completed,
  });

  final int currentGoal;
  final int completed;

  @override
  State<_WeeklyWorkoutGoalDialog> createState() =>
      _WeeklyWorkoutGoalDialogState();
}

class _WeeklyWorkoutGoalDialogState extends State<_WeeklyWorkoutGoalDialog> {
  late int _goal = widget.currentGoal;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AlertDialog(
      title: const Text('Cel na tydzień'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ile treningów chcesz wykonać w tygodniu?',
            style: TextStyle(color: colors.muted),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('decrease_weekly_goal'),
                tooltip: 'Zmniejsz cel',
                onPressed: _goal > AppSettings.minWeeklyWorkoutGoal
                    ? () => setState(() => _goal--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              const SizedBox(width: 14),
              Text(
                '$_goal',
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                key: const Key('increase_weekly_goal'),
                tooltip: 'Zwiększ cel',
                onPressed: _goal < AppSettings.maxWeeklyWorkoutGoal
                    ? () => setState(() => _goal++)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.completed} z $_goal treningów wykonanych w tym tygodniu',
            style: TextStyle(color: colors.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _goal),
          child: const Text('Zapisz cel'),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.accent,
              ),
            ),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(color: colors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
