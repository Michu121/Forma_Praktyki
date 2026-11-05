import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile.dart';

class ProfileDataStore {
  static const _key = 'userProfile.v1';

  Future<UserProfile> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return const UserProfile();

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final sexName = json['sex'] as String?;
    return UserProfile(
      firstName: json['firstName'] as String? ?? 'Michał',
      lastName: json['lastName'] as String? ?? 'Nowak',
      nickname: json['nickname'] as String? ?? '',
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      sex: ReferenceSex.values.firstWhere(
        (sex) => sex.name == sexName,
        orElse: () => ReferenceSex.unspecified,
      ),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      avatarPath: json['avatarPath'] as String?,
      waterTargetOverrideMl: json['waterTargetOverrideMl'] as int?,
      waterReminderEnabled: json['waterReminderEnabled'] as bool? ?? false,
      waterReminderHour: _validComponent(json['waterReminderHour'], 10, 23),
      waterReminderMinute: _validComponent(json['waterReminderMinute'], 0, 59),
    );
  }

  Future<void> save(UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _key,
      jsonEncode({
        'firstName': profile.firstName,
        'lastName': profile.lastName,
        'nickname': profile.nickname,
        'birthDate': profile.birthDate?.toIso8601String(),
        'sex': profile.sex.name,
        'heightCm': profile.heightCm,
        'weightKg': profile.weightKg,
        'avatarPath': profile.avatarPath,
        'waterTargetOverrideMl': profile.waterTargetOverrideMl,
        'waterReminderEnabled': profile.waterReminderEnabled,
        'waterReminderHour': profile.waterReminderHour,
        'waterReminderMinute': profile.waterReminderMinute,
      }),
    );
    if (!saved) throw StateError('Nie udało się zapisać profilu.');
  }

  static int _validComponent(Object? value, int fallback, int maximum) {
    if (value is int && value >= 0 && value <= maximum) return value;
    return fallback;
  }
}
