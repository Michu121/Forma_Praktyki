import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const maxRestSeconds = 3599;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultRestSeconds = 60,
    this.showProfileName = true,
    this.showProfileStats = true,
  });

  final ThemeMode themeMode;
  final int defaultRestSeconds;
  final bool showProfileName;
  final bool showProfileStats;

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? defaultRestSeconds,
    bool? showProfileName,
    bool? showProfileStats,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
    showProfileName: showProfileName ?? this.showProfileName,
    showProfileStats: showProfileStats ?? this.showProfileStats,
  );

  static const _themeKey = 'settings.themeMode';
  static const _restKey = 'settings.defaultRestSeconds';
  static const _profileNameKey = 'settings.showProfileName';
  static const _profileStatsKey = 'settings.showProfileStats';

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedTheme = preferences.getString(_themeKey);
    final themeMode = ThemeMode.values.where(
      (mode) => mode.name == storedTheme,
    );
    final rest = preferences.getInt(_restKey);
    return AppSettings(
      themeMode: themeMode.isEmpty ? ThemeMode.system : themeMode.first,
      defaultRestSeconds: rest != null && rest >= 0 && rest <= maxRestSeconds
          ? rest
          : 60,
      showProfileName: preferences.getBool(_profileNameKey) ?? true,
      showProfileStats: preferences.getBool(_profileStatsKey) ?? true,
    );
  }

  Future<AppSettings> withTheme(ThemeMode value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setString(_themeKey, value.name));
    return AppSettings(
      themeMode: value,
      defaultRestSeconds: defaultRestSeconds,
      showProfileName: showProfileName,
      showProfileStats: showProfileStats,
    );
  }

  Future<AppSettings> withDefaultRest(int value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setInt(_restKey, value));
    return AppSettings(
      themeMode: themeMode,
      defaultRestSeconds: value,
      showProfileName: showProfileName,
      showProfileStats: showProfileStats,
    );
  }

  Future<AppSettings> withProfileName(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setBool(_profileNameKey, value));
    return AppSettings(
      themeMode: themeMode,
      defaultRestSeconds: defaultRestSeconds,
      showProfileName: value,
      showProfileStats: showProfileStats,
    );
  }

  Future<AppSettings> withProfileStats(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    _ensureSaved(await preferences.setBool(_profileStatsKey, value));
    return AppSettings(
      themeMode: themeMode,
      defaultRestSeconds: defaultRestSeconds,
      showProfileName: showProfileName,
      showProfileStats: value,
    );
  }

  static void _ensureSaved(bool saved) {
    if (!saved) throw StateError('Nie udało się zapisać ustawienia lokalnie.');
  }
}
