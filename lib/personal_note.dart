class PersonalNote {
  const PersonalNote({
    required this.id,
    required this.title,
    required this.content,
    this.reminderAt,
  });

  final int id;
  final String title;
  final String content;
  final DateTime? reminderAt;

  PersonalNote copyWith({
    String? title,
    String? content,
    DateTime? reminderAt,
    bool clearReminder = false,
  }) => PersonalNote(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    reminderAt: clearReminder ? null : reminderAt ?? this.reminderAt,
  );
}
