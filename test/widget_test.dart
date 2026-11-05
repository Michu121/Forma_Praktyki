import 'package:flutter/cupertino.dart' show CupertinoTimerPicker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silownia_praktyki/app_colors.dart';
import 'package:silownia_praktyki/app_settings.dart';
import 'package:silownia_praktyki/date_helpers.dart';
import 'package:silownia_praktyki/main.dart';
import 'package:silownia_praktyki/rest_notification_service.dart';
import 'package:silownia_praktyki/workout_models.dart';
import 'package:silownia_praktyki/welcome_message.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows dashboard and navigates to the training plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    expect(find.byKey(const Key('daily_welcome_message')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Twój dzisiejszy plan'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Twój dzisiejszy plan'), findsOneWidget);

    await tester.tap(find.text('Plan').last);
    await tester.pumpAndSettle();

    expect(find.text('Ćwiczenia i zapisane schematy'), findsOneWidget);
    expect(find.text('Wyciskanie sztangi'), findsOneWidget);
    expect(find.text('Zacznij trening'), findsNothing);
  });

  test('exercise catalog includes home, gym, and outdoor options', () {
    expect(exerciseDatabase.length, greaterThan(50));
    expect(
      exerciseDatabase.any((exercise) => exercise.places.contains('Dom')),
      isTrue,
    );
    expect(
      exerciseDatabase.any(
        (exercise) => exercise.places.contains('Na zewnątrz'),
      ),
      isTrue,
    );
    expect(
      exerciseDatabase.any((exercise) => exercise.equipment == 'Bez sprzętu'),
      isTrue,
    );
  });

  test('stores the workout reminder schedule locally', () async {
    const time = TimeOfDay(hour: 7, minute: 30);
    final settings = await const AppSettings().withWorkoutReminders(
      enabled: true,
      days: const [DateTime.monday, DateTime.thursday],
      time: time,
    );
    final loaded = await AppSettings.load();

    expect(settings.workoutRemindersEnabled, isTrue);
    expect(loaded.workoutRemindersEnabled, isTrue);
    expect(loaded.workoutReminderDays, [DateTime.monday, DateTime.thursday]);
    expect(loaded.workoutReminderTime, time);
  });

  test('stores the selected dashboard color palette locally', () async {
    final settings = await const AppSettings().withPalette(GymPalette.ocean);
    final loaded = await AppSettings.load();

    expect(settings.palette, GymPalette.ocean);
    expect(loaded.palette, GymPalette.ocean);
  });

  test('stores a valid weekly workout goal locally', () async {
    final settings = await const AppSettings().withWeeklyWorkoutGoal(6);
    final loaded = await AppSettings.load();

    expect(settings.weeklyWorkoutGoal, 6);
    expect(loaded.weeklyWorkoutGoal, 6);
    await expectLater(settings.withWeeklyWorkoutGoal(15), throwsArgumentError);
  });

  test('counts completed workouts within the current week', () {
    final monday = DateTime(2026, 11, 2);
    final completed = {
      monday,
      monday.add(const Duration(days: 3)),
      monday.add(const Duration(days: 7)),
    };

    expect(workoutsCompletedThisWeek(completed, monday), 2);
  });

  test('welcome messages vary by date and are personalized per user', () {
    final date = DateTime(2026, 11, 4);
    final firstUserGreeting = dailyWelcomeMessage(
      userId: 'user-one',
      userName: 'Anna Kowalska',
      date: date,
    );

    expect(firstUserGreeting, contains('Anna'));
    expect(
      dailyWelcomeMessage(
        userId: 'user-one',
        userName: 'Anna Kowalska',
        date: date,
      ),
      firstUserGreeting,
    );
    expect(
      dailyWelcomeMessage(
        userId: 'user-one',
        userName: 'Anna Kowalska',
        date: date.add(const Duration(days: 1)),
      ),
      isNot(firstUserGreeting),
    );
    expect(
      dailyWelcomeMessage(
        userId: 'user-two',
        userName: 'Piotr Nowak',
        date: date,
      ),
      isNot(firstUserGreeting),
    );
  });

  testWidgets('filters exercise choices by training location', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ustawienia'));
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -750));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utwórz nowy schemat'));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField).last;
    await tester.enterText(searchField, 'Pompki klasyczne');
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Pompki klasyczne'),
      findsOneWidget,
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dom').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Klatka piersiowa').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masa ciała').last);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Pompki klasyczne'),
      findsOneWidget,
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sztanga').last);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Pompki klasyczne'),
      findsNothing,
    );
    expect(find.text('Nie znaleziono ćwiczeń.'), findsOneWidget);

    await tester.enterText(searchField, 'Wyciskanie sztangi');
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(CheckboxListTile, 'Wyciskanie sztangi'),
      findsNothing,
    );
    expect(find.text('Nie znaleziono ćwiczeń.'), findsOneWidget);
  });

  testWidgets('saves weekly workout reminder settings', (
    WidgetTester tester,
  ) async {
    final reminders = _RecordingWorkoutReminders();
    await tester.pumpWidget(GymApp(workoutReminders: reminders));
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Włącz przypomnienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Godzina przypomnienia'), findsNothing);
    expect(find.text('Dni tygodnia'), findsNothing);
    await tester.tap(find.text('Włącz przypomnienia'));
    await tester.pumpAndSettle();

    expect(find.text('Godzina przypomnienia'), findsOneWidget);
    expect(reminders.schedules, hasLength(1));
    expect(reminders.schedules.single.enabled, isTrue);
    expect(reminders.schedules.single.days, [1, 3, 5]);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings.workoutRemindersEnabled'), isTrue);
  });

  testWidgets('opens exercise instructions and tracks completed sets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Plan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wyciskanie sztangi'));
    await tester.pumpAndSettle();

    expect(find.text('Jak wykonać?'), findsOneWidget);
    expect(find.text('Serie: 0 / 4'), findsOneWidget);
    expect(find.text('Zapisz serię'), findsOneWidget);

    await tester.ensureVisible(find.text('Zapisz serię'));
    await tester.tap(find.text('Zapisz serię'));
    await tester.pumpAndSettle();

    expect(find.text('Serie: 1 / 4'), findsOneWidget);
  });

  testWidgets('shows the calendar and account tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    expect(find.text('Kalendarz'), findsNWidgets(2));
    expect(find.text(monthLabel(DateTime.now())), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Michał Nowak'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Cele treningowe'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cele treningowe'), findsOneWidget);
  });

  testWidgets('edits weekly workout goal and shows dashboard progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cele treningowe'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Cele treningowe'));
    await tester.pumpAndSettle();

    expect(find.text('Cel na tydzień'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('increase_weekly_goal')));
    await tester.tap(find.text('Zapisz cel'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('settings.weeklyWorkoutGoal'), 5);

    await tester.tap(find.text('Pulpit'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cel tygodniowy'),
      100,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 z 5 treningów w tym tygodniu'), findsOneWidget);
  });

  testWidgets('awards points when a workout is completed', (
    WidgetTester tester,
  ) async {
    final restNotifications = _RecordingRestNotifications();
    await tester.pumpWidget(GymApp(restNotifications: restNotifications));

    expect(find.text('Nowicjusz · 0 pkt'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Zacznij trening'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zacznij trening'));
    await tester.pumpAndSettle();

    expect(find.text('Góra ciała'), findsWidgets);
    for (var set = 0; set < 13; set++) {
      await tester.ensureVisible(find.textContaining('Zapisz serię'));
      await tester.tap(find.textContaining('Zapisz serię'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Pomiń przerwę'));
      await tester.tap(find.text('Pomiń przerwę'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Wszystkie ćwiczenia wykonane'), findsOneWidget);
    await tester.ensureVisible(find.text('Zakończ i odbierz 100 pkt'));
    await tester.tap(find.text('Zakończ i odbierz 100 pkt'));
    await tester.pumpAndSettle();

    expect(find.text('Trening zaliczony! +100 punktów'), findsOneWidget);
    expect(restNotifications.started, 13);
    expect(restNotifications.finished, 0);
    expect(restNotifications.cancelled, 13);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nowicjusz · 100 pkt'), findsOneWidget);

    await tester.tap(find.text('Pulpit'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Cel tygodniowy'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('1 z 4 treningów w tym tygodniu'), findsOneWidget);

    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Trening wykonany'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Trening wykonany'), findsOneWidget);
  });

  testWidgets('shows the activity chart only on the dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.scrollUntilVisible(
      find.text('Aktywność'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Aktywność'), findsOneWidget);

    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    expect(find.text('Aktywność'), findsNothing);
  });

  testWidgets('creates and stores a named workout template', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ustawienia'));
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -750));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utwórz nowy schemat'));
    await tester.pumpAndSettle();

    expect(find.text('Utwórz schemat treningu'), findsOneWidget);
    expect(find.text('Wyciskanie sztangi'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dół ciała'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nazwa schematu'),
      'Mój trening nóg',
    );
    await tester.tap(find.textContaining('Zapisz schemat'));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('workoutData.v1'),
      contains('Mój trening nóg'),
    );

    await tester.pumpWidget(const GymApp(key: ValueKey('template-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mój trening nóg'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mój trening nóg'), findsOneWidget);
  });

  testWidgets('schedules a template and saves separate day and workout notes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());
    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Wybierz zapisany schemat treningu.'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Wybierz zapisany schemat treningu.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dół ciała').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Dotknij, aby dodać notatkę.').first,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Dotknij, aby dodać notatkę.').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dotknij, aby dodać notatkę.').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Notatka treningu');
    await tester.tap(find.text('Zapisz notatkę'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Dotknij, aby dodać notatkę.'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Dotknij, aby dodać notatkę.').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dotknij, aby dodać notatkę.').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Notatka dnia');
    await tester.tap(find.text('Zapisz notatkę'));
    await tester.pumpAndSettle();

    expect(find.text('Notatka treningu'), findsOneWidget);
    expect(find.text('Notatka dnia'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    final savedData = preferences.getString('workoutData.v1');
    expect(savedData, contains('Notatka treningu'));
    expect(savedData, contains('Notatka dnia'));

    await tester.pumpWidget(const GymApp(key: ValueKey('schedule-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Notatka treningu'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Notatka treningu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Notatka dnia'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Notatka dnia'), findsOneWidget);
  });

  testWidgets('calculates BMI from height and weight', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kalkulator BMI'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kalkulator BMI'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '170');
    await tester.enterText(find.byType(TextField).at(1), '65');
    await tester.tap(find.text('Oblicz BMI'));
    await tester.pumpAndSettle();

    expect(find.text('22.5'), findsOneWidget);
    expect(find.text('Zakres referencyjny'), findsOneWidget);
  });

  testWidgets('changes the appearance theme from profile settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jasny'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('settings.themeMode'), 'light');

    await tester.ensureVisible(find.byTooltip('Niebieski'));
    await tester.tap(find.byTooltip('Niebieski'));
    await tester.pumpAndSettle();

    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    expect(theme.extension<GymColors>()!.accent, const Color(0xFF246DAF));
    expect(preferences.getString('settings.palette'), 'ocean');
  });

  testWidgets('sets the rest time by smoothly scrolling the timer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Domyślna przerwa'));
    await tester.pumpAndSettle();

    expect(
      find.text('Przesuń minuty i sekundy, aby wybrać czas.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    await tester.drag(find.byType(CupertinoTimerPicker), const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz czas'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('settings.defaultRestSeconds'), isNot(60));
  });

  testWidgets('privacy options hide profile details and persist locally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ustawienia'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ustawienia'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Pokaż nazwę profilu'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Pokaż nazwę profilu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pokaż nazwę profilu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Jakie dane są używane?'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gdzie są przechowywane?'), findsOneWidget);
    await tester.tap(find.text('Jakie dane są używane?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Nie wymaga rejestracji konta.'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Michał Nowak'), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings.showProfileName'), isFalse);
  });

  testWidgets('writes and edits a profile training note', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Notatki treningowe'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notatki treningowe'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Kontroluj technikę.');
    await tester.ensureVisible(find.text('Zapisz notatkę'));
    await tester.tap(find.text('Zapisz notatkę'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Notatki treningowe'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Notatki treningowe'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Kontroluj technikę.',
    );
  });
}

class _RecordingRestNotifications implements RestNotificationController {
  int started = 0;
  int finished = 0;
  int cancelled = 0;

  @override
  Future<String?> startRest(Duration duration) async {
    started++;
    return null;
  }

  @override
  Future<void> finishRest() async {
    finished++;
  }

  @override
  Future<void> cancelRest() async {
    cancelled++;
  }
}

class _RecordingWorkoutReminders implements WorkoutReminderController {
  final List<({bool enabled, List<int> days, int hour, int minute})> schedules =
      [];

  @override
  Future<String?> updateWorkoutReminders({
    required bool enabled,
    required List<int> days,
    required int hour,
    required int minute,
  }) async {
    schedules.add((
      enabled: enabled,
      days: [...days],
      hour: hour,
      minute: minute,
    ));
    return null;
  }
}
