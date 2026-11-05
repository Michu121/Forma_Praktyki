import 'package:shared_preferences/shared_preferences.dart';

class HydrationDataStore {
  static const _dateKey = 'hydration.intakeDate';
  static const _intakeKey = 'hydration.intakeMl';

  Future<int> loadToday() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getString(_dateKey) != _dateKeyFor(DateTime.now())) {
      return 0;
    }
    return preferences.getInt(_intakeKey) ?? 0;
  }

  Future<void> saveToday(int amountMl) async {
    if (amountMl < 0) {
      throw ArgumentError.value(amountMl, 'amountMl', 'Nie może być ujemne.');
    }
    final preferences = await SharedPreferences.getInstance();
    final savedDate = await preferences.setString(
      _dateKey,
      _dateKeyFor(DateTime.now()),
    );
    final savedAmount = await preferences.setInt(_intakeKey, amountMl);
    if (!savedDate || !savedAmount) {
      throw StateError('Nie udało się zapisać ilości wypitej wody.');
    }
  }

  static String _dateKeyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
