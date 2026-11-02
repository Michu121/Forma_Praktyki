import 'package:flutter/material.dart';

import 'dart:async';

import 'app_colors.dart';
import 'app_settings.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'date_helpers.dart';
import 'plan_page.dart';
import 'profile_page.dart';
import 'workout_data_store.dart';
import 'workout_models.dart';

void main() {
  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSettings _settings = const AppSettings();
  String? _settingsError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await AppSettings.load();
      if (mounted) setState(() => _settings = settings);
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _settingsError = 'Nie udało się wczytać ustawień: $error');
    }
  }

  Future<void> _updateSettings(
    Future<AppSettings> Function(AppSettings current) update,
  ) async {
    try {
      final settings = await update(_settings);
      if (mounted) {
        setState(() {
          _settings = settings;
          _settingsError = null;
        });
      }
    } on Exception catch (error) {
      if (!mounted) return;
      setState(
        () => _settingsError = 'Nie udało się zapisać ustawienia: $error',
      );
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Nie udało się zapisać ustawienia.')),
      );
    }
  }

  ThemeData _theme(Brightness brightness) {
    final palette = brightness == Brightness.dark
        ? GymColors.dark
        : GymColors.light;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.accent,
        onPrimary: palette.foreground,
        secondary: palette.accent,
        onSecondary: palette.foreground,
        error: const Color(0xFFCF4F4F),
        onError: Colors.white,
        surface: palette.surface,
        onSurface: palette.foreground,
      ),
      extensions: [palette],
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    scaffoldMessengerKey: _messengerKey,
    title: 'Forma',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _settings.themeMode,
    home: GymHomePage(
      settings: _settings,
      settingsError: _settingsError,
      onThemeChanged: (mode) =>
          _updateSettings((value) => value.withTheme(mode)),
      onRestChanged: (seconds) =>
          _updateSettings((value) => value.withDefaultRest(seconds)),
      onProfileNameChanged: (visible) =>
          _updateSettings((value) => value.withProfileName(visible)),
      onProfileStatsChanged: (visible) =>
          _updateSettings((value) => value.withProfileStats(visible)),
    ),
  );
}

class GymHomePage extends StatefulWidget {
  const GymHomePage({
    required this.settings,
    required this.settingsError,
    required this.onThemeChanged,
    required this.onRestChanged,
    required this.onProfileNameChanged,
    required this.onProfileStatsChanged,
    super.key,
  });

  final AppSettings settings;
  final String? settingsError;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<bool> onProfileNameChanged;
  final ValueChanged<bool> onProfileStatsChanged;

  @override
  State<GymHomePage> createState() => _GymHomePageState();
}

class _GymHomePageState extends State<GymHomePage> {
  int _selectedTab = 0;
  final WorkoutDataStore _workoutDataStore = WorkoutDataStore();
  final Set<DateTime> _completedWorkouts = {};
  final Map<DateTime, WorkoutPlan> _workouts = {
    dateOnly(DateTime.now()): planForType(workoutTypes.first),
  };
  final Map<DateTime, String> _dayNotes = {};
  late List<WorkoutPlan> _templates;
  DateTime _selectedDate = dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _templates = workoutTypes.map(planForType).toList();
    unawaited(_loadWorkoutData());
  }

  Future<void> _loadWorkoutData() async {
    try {
      final snapshot = await _workoutDataStore.load();
      if (!mounted || snapshot == null) return;
      setState(() {
        _templates = [..._templates, ...snapshot.templates];
        if (snapshot.scheduledWorkouts.isNotEmpty) {
          _workouts
            ..clear()
            ..addAll(snapshot.scheduledWorkouts);
          _workouts.putIfAbsent(
            dateOnly(DateTime.now()),
            () => planForType(workoutTypes.first),
          );
        }
        _dayNotes
          ..clear()
          ..addAll(snapshot.dayNotes);
      });
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wczytać planów: $error')),
      );
    }
  }

  Future<void> _persistWorkoutData() async {
    try {
      await _workoutDataStore.save(
        templates: _templates.skip(workoutTypes.length).toList(),
        scheduledWorkouts: _workouts,
        dayNotes: _dayNotes,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać planów: $error')),
      );
    }
  }

  int get _points => _completedWorkouts.length * 100;

  WorkoutPlan _planForDate(DateTime date) =>
      _workouts[dateOnly(date)] ?? planForType(workoutTypes.first);

  void _saveWorkout(DateTime date, WorkoutPlan plan) {
    final normalizedDate = dateOnly(date);
    setState(() {
      _workouts[normalizedDate] = plan;
      _selectedDate = normalizedDate;
    });
    unawaited(_persistWorkoutData());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Zapisano trening: ${plan.name}.')));
  }

  void _createTemplate(WorkoutPlan plan) {
    setState(() => _templates.add(plan));
    unawaited(_persistWorkoutData());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Zapisano schemat: ${plan.name}.')));
  }

  void _completeWorkout(DateTime date) {
    final normalizedDate = dateOnly(date);
    if (_completedWorkouts.contains(normalizedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ten trening jest już zaliczony.')),
      );
      return;
    }

    setState(() => _completedWorkouts.add(normalizedDate));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trening zaliczony! +100 punktów')),
    );
  }

  void _saveDayNote(DateTime date, String note) {
    setState(() {
      if (note.trim().isEmpty) {
        _dayNotes.remove(dateOnly(date));
      } else {
        _dayNotes[dateOnly(date)] = note.trim();
      }
    });
    unawaited(_persistWorkoutData());
  }

  void _saveWorkoutNote(DateTime date, String note) {
    final normalizedDate = dateOnly(date);
    final workout = _workouts[normalizedDate];
    if (workout == null) return;
    setState(
      () => _workouts[normalizedDate] = workout.copyWith(note: note.trim()),
    );
    unawaited(_persistWorkoutData());
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final colors = GymColors.of(context);
    final upcoming =
        _workouts.entries.where((entry) => entry.key.isAfter(today)).toList()
          ..sort((first, second) => first.key.compareTo(second.key));
    final nextWorkout = upcoming.isEmpty ? null : upcoming.first;
    final pages = [
      DashboardPage(
        today: today,
        nextWorkout: nextWorkout?.value,
        nextWorkoutDate: nextWorkout?.key,
        points: _points,
        completedWorkouts: _completedWorkouts,
        workout: _planForDate(today),
        isTodayCompleted: _completedWorkouts.contains(today),
        onCompleteWorkout: () => _completeWorkout(today),
        onOpenPlan: () => setState(() => _selectedTab = 1),
        onOpenCalendar: () => setState(() => _selectedTab = 2),
        onCreateTemplate: _createTemplate,
        defaultRestSeconds: widget.settings.defaultRestSeconds,
      ),
      PlanPage(
        date: today,
        workout: _planForDate(today),
        note: _dayNotes[today] ?? '',
        templates: _templates,
        onCreateTemplate: _createTemplate,
        onSaveWorkoutNote: (note) => _saveWorkoutNote(today, note),
        isTodayCompleted: _completedWorkouts.contains(today),
        onSaveNote: (note) => _saveDayNote(today, note),
        onCompleteWorkout: () => _completeWorkout(today),
      ),
      CalendarPage(
        selectedDate: _selectedDate,
        completedWorkouts: _completedWorkouts,
        workouts: _workouts,
        templates: _templates,
        dayNote: _dayNotes[dateOnly(_selectedDate)] ?? '',
        onSelectDate: (date) => setState(() => _selectedDate = dateOnly(date)),
        onSaveWorkout: _saveWorkout,
        onCreateTemplate: _createTemplate,
        onSaveDayNote: _saveDayNote,
        onSaveWorkoutNote: _saveWorkoutNote,
        onCompleteWorkout: _completeWorkout,
        defaultRestSeconds: widget.settings.defaultRestSeconds,
      ),
      ProfilePage(
        points: _points,
        completedWorkouts: _completedWorkouts,
        note: _dayNotes[today] ?? '',
        settings: widget.settings,
        settingsError: widget.settingsError,
        onThemeChanged: widget.onThemeChanged,
        onRestChanged: widget.onRestChanged,
        onProfileNameChanged: widget.onProfileNameChanged,
        onProfileStatsChanged: widget.onProfileStatsChanged,
        onSaveNote: (note) => _saveDayNote(today, note),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: colors.surface,
        indicatorColor: colors.accent.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded, color: colors.muted),
            selectedIcon: Icon(Icons.grid_view_rounded, color: colors.accent),
            label: 'Pulpit',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded, color: colors.muted),
            selectedIcon: Icon(
              Icons.fitness_center_rounded,
              color: colors.accent,
            ),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded, color: colors.muted),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: colors.accent,
            ),
            label: 'Kalendarz',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: colors.muted),
            selectedIcon: Icon(Icons.person_rounded, color: colors.accent),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
