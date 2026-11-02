import 'package:flutter_test/flutter_test.dart';

import 'package:silownia_praktyki/date_helpers.dart';
import 'package:silownia_praktyki/main.dart';

void main() {
  testWidgets('shows dashboard and navigates to the training plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('Gotowy na\nmocny trening?'), findsOneWidget);
    await tester.ensureVisible(find.text('Twój dzisiejszy plan'));
    expect(find.text('Twój dzisiejszy plan'), findsOneWidget);

    await tester.tap(find.text('Plan').last);
    await tester.pumpAndSettle();

    expect(find.text('Plan siłowy • 4 tygodnie'), findsOneWidget);
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
    await tester.ensureVisible(find.text('Cele treningowe'));
    expect(find.text('Cele treningowe'), findsOneWidget);
  });

  testWidgets('awards points when a workout is completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('0 pkt • 100 pkt za trening'), findsOneWidget);
    await tester.ensureVisible(find.text('Zacznij trening'));
    await tester.tap(find.text('Zacznij trening'));
    await tester.pumpAndSettle();

    expect(find.text('Trening góry ciała'), findsOneWidget);
    await tester.ensureVisible(find.text('Zakończ i odbierz 100 pkt'));
    await tester.tap(find.text('Zakończ i odbierz 100 pkt'));
    await tester.pumpAndSettle();

    expect(find.text('100 pkt • 100 pkt za trening'), findsOneWidget);
    expect(find.text('Trening zaliczony'), findsOneWidget);

    await tester.tap(find.text('Kalendarz'));
    await tester.pumpAndSettle();
    expect(find.text('Trening wykonany'), findsOneWidget);
  });
}
