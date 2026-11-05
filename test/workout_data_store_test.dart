import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silownia_praktyki/personal_note.dart';
import 'package:silownia_praktyki/workout_data_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores any number of personal notes and their reminders', () async {
    final reminderAt = DateTime(2026, 11, 6, 18, 30);
    final notes = List.generate(
      200,
      (index) => PersonalNote(
        id: 1000000 + index,
        title: 'Notatka ${index + 1}',
        content: 'Treść ${index + 1}',
        reminderAt: index == 0 ? reminderAt : null,
      ),
    );
    final store = WorkoutDataStore();

    await store.save(
      templates: const [],
      scheduledWorkouts: const {},
      dayNotes: const {},
      personalNotes: notes,
    );
    final snapshot = await store.load();

    expect(snapshot, isNotNull);
    expect(snapshot!.personalNotes, hasLength(200));
    expect(snapshot.personalNotes.first.title, 'Notatka 1');
    expect(snapshot.personalNotes.first.content, 'Treść 1');
    expect(snapshot.personalNotes.first.reminderAt, reminderAt);
    expect(snapshot.personalNotes.last.reminderAt, isNull);
  });
}
