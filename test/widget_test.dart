import 'package:flutter/cupertino.dart' show CupertinoTimerPicker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silownia_praktyki/date_helpers.dart';
import 'package:silownia_praktyki/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows dashboard and navigates to the training plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('Gotowy na\nmocny trening?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Twój dzisiejszy plan'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Twój dzisiejszy plan'), findsOneWidget);

    await tester.tap(find.text('Plan').last);
    await tester.pumpAndSettle();

    expect(find.text('Schemat przypisany do tego dnia'), findsOneWidget);
    expect(find.text('Wyciskanie sztangi'), findsOneWidget);
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

  testWidgets('awards points when a workout is completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('0 pkt • 100 pkt za trening'), findsOneWidget);
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
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('100 pkt • 100 pkt za trening'), findsOneWidget);

    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Trening wykonany'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Trening wykonany'), findsOneWidget);
  });

  testWidgets('creates and stores a named workout template', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    await tester.scrollUntilVisible(
      find.text('Utwórz schemat'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Utwórz schemat'));
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
      find.text('Wybierz zapisany schemat lub utwórz nowy.'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Wybierz zapisany schemat lub utwórz nowy.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dół ciała').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Dotknij, aby dodać notatkę.').first,
      120,
      scrollable: find.byType(Scrollable).first,
    );
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
    await tester.tap(find.text('Dotknij, aby dodać notatkę.'));
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
    await tester.tap(find.text('Motyw aplikacji'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jasny'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('settings.themeMode'), 'light');
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
    await tester.tap(find.text('Pokaż nazwę profilu'));
    await tester.pumpAndSettle();
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
