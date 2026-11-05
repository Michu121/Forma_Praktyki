import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_settings.dart';
import 'common_widgets.dart';
import 'data_storage_page.dart';
import 'rest_duration_picker.dart';
import 'workout_builder_sheet.dart';
import 'workout_models.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
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
    super.key,
  });

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

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings _settings;
  late List<WorkoutPlan> _templates;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _templates = List.of(widget.templates);
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) _settings = widget.settings;
    if (oldWidget.templates != widget.templates) {
      _templates = List.of(widget.templates);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          if (widget.settingsError != null) ...[
            _SettingsErrorBanner(
              message: widget.settingsError!,
              colors: colors,
            ),
            const SizedBox(height: 12),
          ],
          const AppSectionHeading(
            icon: Icons.tune_rounded,
            title: 'Ogólne',
            subtitle: 'Dopasuj wygląd i przebieg treningów.',
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: colors.accent),
                  title: const Text('Motyw aplikacji'),
                  subtitle: Text(
                    '${_themeName(_settings.themeMode)} • ${_settings.palette.label}',
                  ),
                ),
                Divider(height: 1, color: colors.muted.withValues(alpha: 0.16)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jasność',
                        style: TextStyle(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Jasny'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Ciemny'),
                            ),
                          ],
                          selected: {_settings.themeMode},
                          onSelectionChanged: (selection) {
                            final mode = selection.first;
                            setState(
                              () => _settings = _settings.copyWith(
                                themeMode: mode,
                              ),
                            );
                            widget.onThemeChanged(mode);
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Kolor akcentu',
                        style: TextStyle(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          for (final palette in GymPalette.values)
                            Tooltip(
                              message: palette.label,
                              child: Semantics(
                                button: true,
                                selected: _settings.palette == palette,
                                label: 'Kolor ${palette.label}',
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    setState(
                                      () => _settings = _settings.copyWith(
                                        palette: palette,
                                      ),
                                    );
                                    widget.onPaletteChanged(palette);
                                  },
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _settings.palette == palette
                                            ? colors.foreground
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: palette.accentFor(
                                          Theme.of(context).brightness,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _settings.palette == palette
                                          ? Icon(
                                              Icons.check_rounded,
                                              size: 18,
                                              color: colors.background,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.muted.withValues(alpha: 0.16)),
                RestDurationPicker(
                  title: 'Domyślna przerwa',
                  seconds: _settings.defaultRestSeconds,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        defaultRestSeconds: value,
                      ),
                    );
                    widget.onRestChanged(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const AppSectionHeading(
            icon: Icons.fitness_center_outlined,
            title: 'Schematy treningowe',
            subtitle:
                'Twórz własne zestawy ćwiczeń i korzystaj z nich w planie.',
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: Column(
              children: [
                for (var index = 0; index < _templates.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: colors.muted.withValues(alpha: 0.16),
                    ),
                  ListTile(
                    leading: Icon(
                      _templates[index].type.icon,
                      color: colors.accent,
                    ),
                    title: Text(_templates[index].name),
                    subtitle: Text(
                      '${_templates[index].exercises.length} ćwiczeń'
                      ' • przerwa ${_templates[index].restSeconds} s',
                    ),
                  ),
                ],
                if (_templates.isNotEmpty)
                  Divider(
                    height: 1,
                    color: colors.muted.withValues(alpha: 0.16),
                  ),
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline_rounded,
                    color: colors.accent,
                  ),
                  title: const Text('Utwórz nowy schemat'),
                  subtitle: const Text('Wybierz ćwiczenia i nadaj mu nazwę.'),
                  onTap: () => _createTemplate(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          AppSectionHeading(
            icon: Icons.notifications_active_outlined,
            title: 'Przypomnienia o treningu',
            subtitle: _settings.workoutRemindersEnabled
                ? 'Wybierz dni tygodnia i godzinę powiadomień.'
                : 'Włącz przypomnienia, aby ustawić harmonogram.',
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: colors.accent,
                  ),
                  title: const Text('Włącz przypomnienia'),
                  subtitle: _settings.workoutRemindersEnabled
                      ? Text(
                          'Otrzymasz ${_settings.workoutReminderDays.length} '
                          'powiadomień tygodniowo.',
                        )
                      : null,
                  value: _settings.workoutRemindersEnabled,
                  onChanged: (enabled) => _updateReminderSettings(
                    _settings.copyWith(workoutRemindersEnabled: enabled),
                  ),
                ),
                if (_settings.workoutRemindersEnabled)
                  Divider(
                    height: 1,
                    color: colors.muted.withValues(alpha: 0.16),
                  ),
                if (_settings.workoutRemindersEnabled)
                  ListTile(
                    leading: Icon(Icons.schedule_rounded, color: colors.accent),
                    title: const Text('Godzina przypomnienia'),
                    subtitle: Text(
                      _settings.workoutReminderTime.format(context),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _chooseReminderTime,
                  ),
                if (_settings.workoutRemindersEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dni tygodnia',
                          style: TextStyle(
                            color: colors.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 4,
                          children: [
                            for (final day in _weekdays)
                              FilterChip(
                                label: Text(day.$2),
                                selected: _settings.workoutReminderDays
                                    .contains(day.$1),
                                onSelected: (selected) {
                                  final days = [
                                    ..._settings.workoutReminderDays,
                                  ];
                                  if (selected) {
                                    days.add(day.$1);
                                  } else {
                                    days.remove(day.$1);
                                  }
                                  if (days.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Wybierz przynajmniej jeden dzień.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _updateReminderSettings(
                                    _settings.copyWith(
                                      workoutReminderDays: days,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const AppSectionHeading(
            icon: Icons.shield_outlined,
            title: 'Prywatność',
            subtitle:
                'Sprawdź, jakie dane zapisuje aplikacja i jak nimi zarządzać.',
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.person_outline_rounded,
                    color: colors.accent,
                  ),
                  title: const Text('Pokaż nazwę profilu'),
                  subtitle: const Text(
                    'Ukryj nazwę na profilu i w codziennym powitaniu.',
                  ),
                  value: _settings.showProfileName,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        showProfileName: value,
                      ),
                    );
                    widget.onProfileNameChanged(value);
                  },
                ),
                Divider(height: 1, color: colors.muted.withValues(alpha: 0.16)),
                SwitchListTile(
                  secondary: Icon(
                    Icons.insights_outlined,
                    color: colors.accent,
                  ),
                  title: const Text('Pokaż statystyki profilu'),
                  subtitle: const Text(
                    'Ukryj liczbę treningów, czas i punkty na profilu.',
                  ),
                  value: _settings.showProfileStats,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        showProfileStats: value,
                      ),
                    );
                    widget.onProfileStatsChanged(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const AppSectionHeading(
            icon: Icons.storage_outlined,
            title: 'Dane i przechowywanie',
            subtitle: 'Zobacz, co zapisuje aplikacja i gdzie.',
          ),
          const SizedBox(height: 10),
          AppSurfaceCard(
            child: ListTile(
              leading: Icon(Icons.storage_outlined, color: colors.accent),
              title: const Text('Dane i przechowywanie'),
              subtitle: const Text(
                'Informacje o danych, powiadomieniach i ich usuwaniu.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const DataStoragePage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _weekdays = [
    (DateTime.monday, 'Pon'),
    (DateTime.tuesday, 'Wt'),
    (DateTime.wednesday, 'Śr'),
    (DateTime.thursday, 'Czw'),
    (DateTime.friday, 'Pt'),
    (DateTime.saturday, 'Sob'),
    (DateTime.sunday, 'Niedz'),
  ];

  void _updateReminderSettings(AppSettings settings) {
    setState(() => _settings = settings);
    widget.onWorkoutReminderScheduleChanged(settings);
  }

  Future<void> _chooseReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _settings.workoutReminderTime,
      helpText: 'Godzina przypomnienia',
    );
    if (time == null || !mounted) return;
    _updateReminderSettings(_settings.copyWith(workoutReminderTime: time));
  }

  Future<void> _createTemplate(BuildContext context) async {
    final template = await showWorkoutBuilder(
      context,
      defaultRestSeconds: widget.defaultRestSeconds,
    );
    if (template == null || !mounted) return;
    setState(() => _templates = [..._templates, template]);
    widget.onCreateTemplate(template);
  }

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Zgodny z ustawieniami systemu',
    ThemeMode.light => 'Jasny',
    ThemeMode.dark => 'Ciemny',
  };
}

class _SettingsErrorBanner extends StatelessWidget {
  const _SettingsErrorBanner({required this.message, required this.colors});

  final String message;
  final GymColors colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(appCompactRadius),
    ),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: colors.foreground, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
