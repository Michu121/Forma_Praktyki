import 'dart:io';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_settings.dart';
import 'bmi_calculator_page.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'note_editor.dart';
import 'profile_editor_page.dart';
import 'settings_page.dart';
import 'user_profile.dart';
import 'workout_models.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.points,
    required this.completedWorkouts,
    required this.note,
    required this.profile,
    required this.waterIntakeMl,
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
    required this.onSaveProfile,
    required this.onWaterIntakeChanged,
    super.key,
  });

  final int points;
  final Set<DateTime> completedWorkouts;
  final String note;
  final UserProfile profile;
  final int waterIntakeMl;
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
  final Future<void> Function(UserProfile profile) onSaveProfile;
  final Future<void> Function(int amountMl) onWaterIntakeChanged;

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
              CircleAvatar(
                radius: 44,
                backgroundColor: colors.accent.withValues(alpha: 0.15),
                foregroundImage: profile.avatarPath == null
                    ? null
                    : FileImage(File(profile.avatarPath!)),
                child: profile.avatarPath == null
                    ? Icon(Icons.person_rounded, size: 44, color: colors.accent)
                    : null,
              ),
              if (settings.showProfileStats &&
                  (profile.ageAt(DateTime.now()) != null ||
                      profile.heightCm != null ||
                      profile.weightKg != null)) ...[
                const SizedBox(height: 7),
                Text(
                  [
                    if (profile.ageAt(DateTime.now()) case final age?)
                      '$age lat',
                    if (profile.heightCm case final height?)
                      '${height.toStringAsFixed(0)} cm',
                    if (profile.weightKg case final weight?)
                      '${weight.toStringAsFixed(1)} kg',
                  ].join(' • '),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 14),
              if (settings.showProfileName)
                Text(
                  profile.displayName,
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
        const SectionTitle('Nawodnienie'),
        const SizedBox(height: 12),
        _WaterIntakeCard(
          amountMl: waterIntakeMl,
          targetMl: profile.dailyWaterTargetMl,
          onAddAmount: (amount) => onWaterIntakeChanged(waterIntakeMl + amount),
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
          icon: Icons.manage_accounts_outlined,
          title: 'Edytuj profil',
          subtitle: 'Imię, nazwisko, pseudonim, zdjęcie i dane ciała',
          onTap: () => _editProfile(context),
        ),
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
              ' z ${settings.weeklyWorkoutGoal} treningów w tym tygodniu'
              ' • porównanie po zebraniu danych',
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

  Future<void> _editProfile(BuildContext context) async {
    final updatedProfile = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute<UserProfile>(
        builder: (_) => ProfileEditorPage(profile: profile),
      ),
    );
    if (updatedProfile != null) await onSaveProfile(updatedProfile);
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
          const SizedBox(height: 12),
          Text(
            'Porównanie z innymi użytkownikami pojawi się po zebraniu '
            'wystarczającej liczby zagregowanych celów tygodniowych.',
            style: TextStyle(color: colors.muted, fontSize: 11, height: 1.4),
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

class _WaterIntakeCard extends StatelessWidget {
  const _WaterIntakeCard({
    required this.amountMl,
    required this.targetMl,
    required this.onAddAmount,
  });

  final int amountMl;
  final int targetMl;
  final ValueChanged<int> onAddAmount;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final progress = (amountMl / targetMl).clamp(0.0, 1.0);
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop_outlined, color: colors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Wypite napoje: ${_litersLabel(amountMl)} / ${_litersLabel(targetMl)}',
                    style: TextStyle(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: colors.surfaceLight,
              color: colors.accent,
            ),
            const SizedBox(height: 8),
            Text(
              'Dzisiejsze wpisy dotyczą napojów; cel orientacyjny EFSA '
              'obejmuje też wodę z żywności.',
              style: TextStyle(color: colors.muted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => onAddAmount(250),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('250 ml'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onAddAmount(500),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('500 ml'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _litersLabel(int amountMl) =>
      '${(amountMl / 1000).toStringAsFixed(1)} l';
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
