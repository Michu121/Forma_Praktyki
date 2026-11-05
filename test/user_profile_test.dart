import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:silownia_praktyki/profile_data_store.dart';
import 'package:silownia_praktyki/user_profile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses the selected age and sex reference for water estimates', () {
    final today = DateTime.now();
    final adultBirthDate = DateTime(today.year - 30, today.month, today.day);
    final female = UserProfile(
      birthDate: adultBirthDate,
      sex: ReferenceSex.female,
      heightCm: 165,
      weightKg: 60,
    );
    final male = UserProfile(
      birthDate: adultBirthDate,
      sex: ReferenceSex.male,
      heightCm: 180,
      weightKg: 80,
    );

    expect(female.ageAt(today), 30);
    expect(female.suggestedWaterTargetMl, 2000);
    expect(male.suggestedWaterTargetMl, 2500);
    expect(
      female.copyWith(waterTargetOverrideMl: 1800).dailyWaterTargetMl,
      1800,
    );
  });

  test('stores profile details and hydration preferences locally', () async {
    final profile = UserProfile(
      firstName: 'Anna',
      lastName: 'Kowalska',
      nickname: 'Anka',
      birthDate: DateTime(1995, 6, 12),
      sex: ReferenceSex.female,
      heightCm: 168,
      weightKg: 62.5,
      avatarPath: r'C:\profile\avatar.jpg',
      waterTargetOverrideMl: 2100,
      waterReminderEnabled: true,
      waterReminderHour: 9,
      waterReminderMinute: 15,
    );
    final store = ProfileDataStore();

    await store.save(profile);
    final loaded = await store.load();

    expect(loaded.firstName, profile.firstName);
    expect(loaded.lastName, profile.lastName);
    expect(loaded.nickname, profile.nickname);
    expect(loaded.birthDate, profile.birthDate);
    expect(loaded.sex, profile.sex);
    expect(loaded.heightCm, profile.heightCm);
    expect(loaded.weightKg, profile.weightKg);
    expect(loaded.avatarPath, profile.avatarPath);
    expect(loaded.dailyWaterTargetMl, 2100);
    expect(loaded.waterReminderEnabled, isTrue);
    expect(loaded.waterReminderHour, 9);
    expect(loaded.waterReminderMinute, 15);
  });
}
