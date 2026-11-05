import 'package:flutter/material.dart';

import 'dart:async';

import 'app_colors.dart';
import 'app_settings.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'date_helpers.dart';
import 'hydration_data_store.dart';
import 'notes_page.dart';
import 'plan_page.dart';
import 'personal_note.dart';
import 'profile_data_store.dart';
import 'profile_page.dart';
import 'rest_notification_service.dart';
import 'user_profile.dart';
import 'workout_data_store.dart';
import 'workout_models.dart';
import 'welcome_message.dart';

void main() {
  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({
    this.restNotifications,
    this.workoutReminders,
    this.noteReminders,
    this.hydrationReminders,
    super.key,
  });

  final RestNotificationController? restNotifications;
  final WorkoutReminderController? workoutReminders;
  final NoteReminderController? noteReminders;
  final HydrationReminderController? hydrationReminders;

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

  Future<void> _updateWorkoutReminderSettings(AppSettings requested) async {
    try {
      final settings = await _settings.withWorkoutReminders(
        enabled: requested.workoutRemindersEnabled,
        days: requested.workoutReminderDays,
        time: requested.workoutReminderTime,
      );
      if (mounted) setState(() => _settings = settings);

      final reminderController =
          widget.workoutReminders ?? RestNotificationService.instance;
      final warning = await reminderController.updateWorkoutReminders(
        enabled: settings.workoutRemindersEnabled,
        days: settings.workoutReminderDays,
        hour: settings.workoutReminderTime.hour,
        minute: settings.workoutReminderTime.minute,
      );
      if (warning != null && mounted) {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(warning)),
        );
      }
    } on Exception catch (error) {
      if (!mounted) return;
      setState(
        () => _settingsError = 'Nie udało się ustawić przypomnień: $error',
      );
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Nie udało się ustawić przypomnień.')),
      );
    }
  }

  ThemeData _theme(Brightness brightness) {
    final palette = GymColors.forPalette(_settings.palette, brightness);
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
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appCardRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appCardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appCompactRadius),
          borderSide: BorderSide(color: palette.muted.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appCompactRadius),
          borderSide: BorderSide(color: palette.muted.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appCompactRadius),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surfaceLight,
        contentTextStyle: TextStyle(color: palette.foreground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appCompactRadius),
        ),
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
      restNotifications:
          widget.restNotifications ?? RestNotificationService.instance,
      noteReminders: widget.noteReminders ?? RestNotificationService.instance,
      hydrationReminders:
          widget.hydrationReminders ?? RestNotificationService.instance,
      settings: _settings,
      settingsError: _settingsError,
      onThemeChanged: (mode) =>
          _updateSettings((value) => value.withTheme(mode)),
      onPaletteChanged: (palette) =>
          _updateSettings((value) => value.withPalette(palette)),
      onRestChanged: (seconds) =>
          _updateSettings((value) => value.withDefaultRest(seconds)),
      onProfileNameChanged: (visible) =>
          _updateSettings((value) => value.withProfileName(visible)),
      onProfileStatsChanged: (visible) =>
          _updateSettings((value) => value.withProfileStats(visible)),
      onWorkoutReminderScheduleChanged: _updateWorkoutReminderSettings,
      onWeeklyWorkoutGoalChanged: (goal) =>
          _updateSettings((value) => value.withWeeklyWorkoutGoal(goal)),
    ),
  );
}

class GymHomePage extends StatefulWidget {
  const GymHomePage({
    required this.restNotifications,
    required this.noteReminders,
    required this.hydrationReminders,
    required this.settings,
    required this.settingsError,
    required this.onThemeChanged,
    required this.onPaletteChanged,
    required this.onRestChanged,
    required this.onProfileNameChanged,
    required this.onProfileStatsChanged,
    required this.onWorkoutReminderScheduleChanged,
    required this.onWeeklyWorkoutGoalChanged,
    super.key,
  });

  final RestNotificationController restNotifications;
  final NoteReminderController noteReminders;
  final HydrationReminderController hydrationReminders;
  final AppSettings settings;
  final String? settingsError;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<GymPalette> onPaletteChanged;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<bool> onProfileNameChanged;
  final ValueChanged<bool> onProfileStatsChanged;
  final ValueChanged<AppSettings> onWorkoutReminderScheduleChanged;
  final ValueChanged<int> onWeeklyWorkoutGoalChanged;

  @override
  State<GymHomePage> createState() => _GymHomePageState();
}

class _GymHomePageState extends State<GymHomePage> {
  int _selectedTab = 0;
  final WorkoutDataStore _workoutDataStore = WorkoutDataStore();
  final ProfileDataStore _profileDataStore = ProfileDataStore();
  final HydrationDataStore _hydrationDataStore = HydrationDataStore();
  final Set<DateTime> _completedWorkouts = {};
  final Map<DateTime, WorkoutPlan> _workouts = {
    dateOnly(DateTime.now()): planForType(workoutTypes.first),
  };
  final Map<DateTime, String> _dayNotes = {};
  final List<PersonalNote> _personalNotes = [];
  UserProfile _profile = const UserProfile();
  int _waterIntakeMl = 0;
  late List<WorkoutPlan> _templates;
  DateTime _selectedDate = dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _templates = workoutTypes.map(planForType).toList();
    unawaited(_loadWorkoutData());
    unawaited(_loadProfile());
    unawaited(_loadWaterIntake());
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileDataStore.load();
      if (mounted) setState(() => _profile = profile);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wczytać profilu: $error')),
      );
    }
  }

  Future<void> _loadWaterIntake() async {
    try {
      final amount = await _hydrationDataStore.loadToday();
      if (mounted) setState(() => _waterIntakeMl = amount);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nie udało się wczytać dzisiejszego nawodnienia: $error',
          ),
        ),
      );
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final previous = _profile;
    try {
      await _profileDataStore.save(profile);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać profilu: $error')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _profile = profile);

    final reminderSettingsChanged =
        previous.waterReminderEnabled != profile.waterReminderEnabled ||
        previous.waterReminderHour != profile.waterReminderHour ||
        previous.waterReminderMinute != profile.waterReminderMinute ||
        previous.dailyWaterTargetMl != profile.dailyWaterTargetMl;
    if (!reminderSettingsChanged ||
        (!previous.waterReminderEnabled && !profile.waterReminderEnabled)) {
      return;
    }

    try {
      final warning = await widget.hydrationReminders.updateHydrationReminder(
        enabled: profile.waterReminderEnabled,
        hour: profile.waterReminderHour,
        minute: profile.waterReminderMinute,
        targetMl: profile.dailyWaterTargetMl,
        color: GymColors.of(context).accent,
      );
      if (warning != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(warning)));
      }
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nie udało się ustawić przypomnienia o wodzie: $error'),
        ),
      );
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Przypomnienia są niedostępne: $error')),
      );
    }
  }

  Future<void> _saveWaterIntake(int amountMl) async {
    setState(() => _waterIntakeMl = amountMl);
    try {
      await _hydrationDataStore.saveToday(amountMl);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać ilości wody: $error')),
      );
    }
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
        _personalNotes
          ..clear()
          ..addAll(snapshot.personalNotes);
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
        personalNotes: _personalNotes,
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

  Future<void> _savePersonalNote(PersonalNote note) async {
    final previousIndex = _personalNotes.indexWhere(
      (savedNote) => savedNote.id == note.id,
    );
    final previous = previousIndex < 0 ? null : _personalNotes[previousIndex];
    setState(() {
      if (previousIndex < 0) {
        _personalNotes.add(note);
      } else {
        _personalNotes[previousIndex] = note;
      }
    });
    await _persistWorkoutData();
    if (!mounted) return;

    final reminderAt = note.reminderAt;
    if (reminderAt == null) {
      if (previous?.reminderAt == null) return;
      try {
        await widget.noteReminders.cancelNoteReminder(note.id);
      } on Exception catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie udało się anulować przypomnienia: $error'),
          ),
        );
      } on UnsupportedError catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Przypomnienia są niedostępne: $error')),
        );
      }
      return;
    }

    try {
      final warning = await widget.noteReminders.scheduleNoteReminder(
        id: note.id,
        title: note.title,
        content: note.content,
        reminderAt: reminderAt,
        color: GymColors.of(context).accent,
      );
      if (warning != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(warning)));
      }
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się ustawić przypomnienia: $error')),
      );
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Przypomnienia są niedostępne: $error')),
      );
    }
  }

  Future<void> _deletePersonalNote(PersonalNote note) async {
    setState(
      () => _personalNotes.removeWhere((savedNote) => savedNote.id == note.id),
    );
    await _persistWorkoutData();
    if (!mounted) return;
    if (note.reminderAt == null) return;
    try {
      await widget.noteReminders.cancelNoteReminder(note.id);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się anulować przypomnienia: $error')),
      );
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Przypomnienia są niedostępne: $error')),
      );
    }
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
        weeklyWorkoutGoal: widget.settings.weeklyWorkoutGoal,
        userId: defaultProfileId,
        userName: widget.settings.showProfileName ? _profile.displayName : null,
        workout: _planForDate(today),
        isTodayCompleted: _completedWorkouts.contains(today),
        onCompleteWorkout: () => _completeWorkout(today),
        onOpenPlan: () => setState(() => _selectedTab = 1),
        onOpenCalendar: () => setState(() => _selectedTab = 2),
        onOpenProfile: () => setState(() => _selectedTab = 4),
        defaultRestSeconds: widget.settings.defaultRestSeconds,
        restNotifications: widget.restNotifications,
      ),
      PlanPage(
        date: today,
        workout: _planForDate(today),
        note: _dayNotes[today] ?? '',
        templates: _templates,
        onSaveWorkoutNote: (note) => _saveWorkoutNote(today, note),
        onSaveNote: (note) => _saveDayNote(today, note),
      ),
      CalendarPage(
        selectedDate: _selectedDate,
        completedWorkouts: _completedWorkouts,
        workouts: _workouts,
        templates: _templates,
        dayNote: _dayNotes[dateOnly(_selectedDate)] ?? '',
        onSelectDate: (date) => setState(() => _selectedDate = dateOnly(date)),
        onSaveWorkout: _saveWorkout,
        onSaveDayNote: _saveDayNote,
        onSaveWorkoutNote: _saveWorkoutNote,
        onCompleteWorkout: _completeWorkout,
        restNotifications: widget.restNotifications,
      ),
      NotesPage(
        notes: _personalNotes,
        onSaveNote: _savePersonalNote,
        onDeleteNote: _deletePersonalNote,
      ),
      ProfilePage(
        points: _points,
        completedWorkouts: _completedWorkouts,
        note: _dayNotes[today] ?? '',
        profile: _profile,
        waterIntakeMl: _waterIntakeMl,
        settings: widget.settings,
        settingsError: widget.settingsError,
        templates: _templates,
        defaultRestSeconds: widget.settings.defaultRestSeconds,
        onCreateTemplate: _createTemplate,
        onThemeChanged: widget.onThemeChanged,
        onPaletteChanged: widget.onPaletteChanged,
        onRestChanged: widget.onRestChanged,
        onProfileNameChanged: widget.onProfileNameChanged,
        onProfileStatsChanged: widget.onProfileStatsChanged,
        onWorkoutReminderScheduleChanged:
            widget.onWorkoutReminderScheduleChanged,
        onWeeklyWorkoutGoalChanged: widget.onWeeklyWorkoutGoalChanged,
        onSaveNote: (note) => _saveDayNote(today, note),
        onSaveProfile: _saveProfile,
        onWaterIntakeChanged: _saveWaterIntake,
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
            icon: Icon(Icons.notes_rounded, color: colors.muted),
            selectedIcon: Icon(Icons.notes_rounded, color: colors.accent),
            label: 'Notatki',
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
