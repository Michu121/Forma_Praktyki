import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

class AppSettings {
  static const maxRestSeconds = 3599;
  static const minWeeklyWorkoutGoal = 1;
  static const maxWeeklyWorkoutGoal = 14;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.palette = GymPalette.lime,
    this.weeklyWorkoutGoal = 4,
    this.defaultRestSeconds = 60,
    this.showProfileName = true,
    this.showProfileStats = true,
    this.workoutRemindersEnabled = false,
    this.workoutReminderDays = const [1, 3, 5],
    this.workoutReminderTime = const TimeOfDay(hour: 18, minute: 0),
  });

  final ThemeMode themeMode;
  final GymPalette palette;
  final int weeklyWorkoutGoal;
  final int defaultRestSeconds;
  final bool showProfileName;
  final bool showProfileStats;
  final bool workoutRemindersEnabled;
  final List<int> workoutReminderDays;
  final TimeOfDay workoutReminderTime;

  AppSettings copyWith({
    ThemeMode? themeMode,
    GymPalette? palette,
    int? weeklyWorkoutGoal,
    int? defaultRestSeconds,
    bool? showProfileName,
    bool? showProfileStats,
    bool? workoutRemindersEnabled,
    List<int>? workoutReminderDays,
    TimeOfDay? workoutReminderTime,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    palette: palette ?? this.palette,
    weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
    defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
    showProfileName: showProfileName ?? this.showProfileName,
    showProfileStats: showProfileStats ?? this.showProfileStats,
    workoutRemindersEnabled:
        workoutRemindersEnabled ?? this.workoutRemindersEnabled,
    workoutReminderDays: workoutReminderDays ?? this.workoutReminderDays,
    workoutReminderTime: workoutReminderTime ?? this.workoutReminderTime,
  );

  static const _themeKey = 'settings.themeMode';
  static const _paletteKey = 'settings.palette';
  static const _weeklyWorkoutGoalKey = 'settings.weeklyWorkoutGoal';
  static const _restKey = 'settings.defaultRestSeconds';
  static const _profileNameKey = 'settings.showProfileName';
  static const _profileStatsKey = 'settings.showProfileStats';
  static const _workoutRemindersEnabledKey = 'settings.workoutRemindersEnabled';
  static const _workoutReminderDaysKey = 'settings.workoutReminderDays';
  static const _workoutReminderHourKey = 'settings.workoutReminderHour';
  static const _workoutReminderMinuteKey = 'settings.workoutReminderMinute';

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedTheme = preferences.getString(_themeKey);
    final storedPalette = preferences.getString(_paletteKey);
    final themeMode = ThemeMode.values.where(
      (mode) => mode.name == storedTheme,
    );
    final rest = preferences.getInt(_restKey);
    return AppSettings(
      themeMode: themeMode.isEmpty ? ThemeMode.system : themeMode.first,
      palette: GymPalette.values.firstWhere(
        (palette) => palette.name == storedPalette,
        orElse: () => GymPalette.lime,
      ),
      weeklyWorkoutGoal: _validWeeklyWorkoutGoal(
        preferences.getInt(_weeklyWorkoutGoalKey),
      ),
      defaultRestSeconds: rest != null && rest >= 0 && rest <= maxRestSeconds
          ? rest
          : 60,
      showProfileName: preferences.getBool(_profileNameKey) ?? true,
      showProfileStats: preferences.getBool(_profileStatsKey) ?? true,
      workoutRemindersEnabled:
          preferences.getBool(_workoutRemindersEnabledKey) ?? false,
      workoutReminderDays: _validWeekdays(
        preferences.getStringList(_workoutReminderDaysKey),
      ),
      workoutReminderTime: TimeOfDay(
        hour: _validTimeComponent(
          preferences.getInt(_workoutReminderHourKey),
          maximum: 23,
          fallback: 18,
        ),
        minute: _validTimeComponent(
          preferences.getInt(_workoutReminderMinuteKey),
          maximum: 59,
          fallback: 0,
        ),
      ),
    );
  }

  Future<AppSettings> withTheme(ThemeMode value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setString(_themeKey, value.name));
    return copyWith(themeMode: value);
  }

  Future<AppSettings> withPalette(GymPalette value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setString(_paletteKey, value.name));
    return copyWith(palette: value);
  }

  Future<AppSettings> withWeeklyWorkoutGoal(int value) async {
    if (value < minWeeklyWorkoutGoal || value > maxWeeklyWorkoutGoal) {
      throw ArgumentError.value(value, 'value', 'Cel musi być od 1 do 14.');
    }
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setInt(_weeklyWorkoutGoalKey, value));
    return copyWith(weeklyWorkoutGoal: value);
  }

  Future<AppSettings> withDefaultRest(int value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setInt(_restKey, value));
    return copyWith(defaultRestSeconds: value);
  }

  Future<AppSettings> withProfileName(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setBool(_profileNameKey, value));
    return copyWith(showProfileName: value);
  }

  Future<AppSettings> withProfileStats(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setBool(_profileStatsKey, value));
    return copyWith(showProfileStats: value);
  }

  Future<AppSettings> withWorkoutReminders({
    required bool enabled,
    required List<int> days,
    required TimeOfDay time,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final savedEnabled = await preferences.setBool(
      _workoutRemindersEnabledKey,
      enabled,
    );
    final savedDays = await preferences.setStringList(
      _workoutReminderDaysKey,
      (days.toSet().toList()..sort()).map((day) => '$day').toList(),
    );
    final savedHour = await preferences.setInt(
      _workoutReminderHourKey,
      time.hour,
    );
    final savedMinute = await preferences.setInt(
      _workoutReminderMinuteKey,
      time.minute,
    );
    _ensureSaved(savedEnabled && savedDays && savedHour && savedMinute);
    return copyWith(
      workoutRemindersEnabled: enabled,
      workoutReminderDays: List.unmodifiable(days.toSet().toList()..sort()),
      workoutReminderTime: time,
    );
  }

  static List<int> _validWeekdays(List<String>? values) {
    if (values == null) return const [1, 3, 5];
    final days =
        values
            .map(int.tryParse)
            .whereType<int>()
            .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
            .toSet()
            .toList()
          ..sort();
    return days.isEmpty ? const [1, 3, 5] : days;
  }

  static int _validTimeComponent(
    int? value, {
    required int maximum,
    required int fallback,
  }) => value != null && value >= 0 && value <= maximum ? value : fallback;

  static int _validWeeklyWorkoutGoal(int? value) =>
      value != null &&
          value >= minWeeklyWorkoutGoal &&
          value <= maxWeeklyWorkoutGoal
      ? value
      : 4;

  static void _ensureSaved(bool saved) {
    if (!saved) throw StateError('Nie udało się zapisać ustawienia lokalnie.');
  }
}
