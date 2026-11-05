enum ReferenceSex { female, male, unspecified }

class UserProfile {
  const UserProfile({
    this.firstName = 'Michał',
    this.lastName = 'Nowak',
    this.nickname = '',
    this.birthDate,
    this.sex = ReferenceSex.unspecified,
    this.heightCm,
    this.weightKg,
    this.avatarPath,
    this.waterTargetOverrideMl,
    this.waterReminderEnabled = false,
    this.waterReminderHour = 10,
    this.waterReminderMinute = 0,
  });

  final String firstName;
  final String lastName;
  final String nickname;
  final DateTime? birthDate;
  final ReferenceSex sex;
  final double? heightCm;
  final double? weightKg;
  final String? avatarPath;
  final int? waterTargetOverrideMl;
  final bool waterReminderEnabled;
  final int waterReminderHour;
  final int waterReminderMinute;

  String get displayName {
    final chosenName = nickname.trim();
    if (chosenName.isNotEmpty) return chosenName;
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Profil treningowy' : fullName;
  }

  int? ageAt(DateTime date) {
    final dateOfBirth = birthDate;
    if (dateOfBirth == null) return null;
    var age = date.year - dateOfBirth.year;
    if (date.month < dateOfBirth.month ||
        (date.month == dateOfBirth.month && date.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int get suggestedWaterTargetMl {
    final age = ageAt(DateTime.now());
    if (age != null && age < 1) return 900;
    if (age != null && age < 2) return 1150;
    if (age != null && age < 4) return 1300;
    if (age != null && age <= 8) return 1600;
    if (age != null && age <= 13) {
      return switch (sex) {
        ReferenceSex.female => 1900,
        ReferenceSex.male => 2100,
        ReferenceSex.unspecified => 2000,
      };
    }
    return switch (sex) {
      ReferenceSex.female => 2000,
      ReferenceSex.male => 2500,
      ReferenceSex.unspecified => 2250,
    };
  }

  int get dailyWaterTargetMl => waterTargetOverrideMl ?? suggestedWaterTargetMl;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? nickname,
    DateTime? birthDate,
    bool clearBirthDate = false,
    ReferenceSex? sex,
    double? heightCm,
    bool clearHeight = false,
    double? weightKg,
    bool clearWeight = false,
    String? avatarPath,
    bool clearAvatar = false,
    int? waterTargetOverrideMl,
    bool clearWaterTargetOverride = false,
    bool? waterReminderEnabled,
    int? waterReminderHour,
    int? waterReminderMinute,
  }) => UserProfile(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    nickname: nickname ?? this.nickname,
    birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
    sex: sex ?? this.sex,
    heightCm: clearHeight ? null : heightCm ?? this.heightCm,
    weightKg: clearWeight ? null : weightKg ?? this.weightKg,
    avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    waterTargetOverrideMl: clearWaterTargetOverride
        ? null
        : waterTargetOverrideMl ?? this.waterTargetOverrideMl,
    waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
    waterReminderHour: waterReminderHour ?? this.waterReminderHour,
    waterReminderMinute: waterReminderMinute ?? this.waterReminderMinute,
  );
}
