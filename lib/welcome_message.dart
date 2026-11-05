const defaultProfileId = 'local-profile-michal-nowak';
const defaultProfileName = 'Michał Nowak';

const _personalizedGreetings = [
  'Miło Cię widzieć, {name}!',
  'Gotowy na kolejny krok, {name}?',
  'Nowy dzień, nowa szansa, {name}!',
  'Dobrze, że wracasz, {name}!',
  'Czas zrobić coś dobrego dla siebie, {name}.',
  'Twój trening zaczyna się od decyzji, {name}.',
];

const _genericGreetings = [
  'Miło Cię widzieć!',
  'Gotowy na kolejny krok?',
  'Nowy dzień, nowa szansa!',
  'Dobrze, że wracasz!',
  'Czas zrobić coś dobrego dla siebie.',
  'Twój trening zaczyna się od decyzji.',
];

String dailyWelcomeMessage({
  required String userId,
  required DateTime date,
  String? userName,
}) {
  final normalizedName = userName?.trim();
  final greetings = normalizedName == null || normalizedName.isEmpty
      ? _genericGreetings
      : _personalizedGreetings;
  final firstName = normalizedName?.split(RegExp(r'\s+')).first;
  final dayKey = '${date.year}-${date.month}-${date.day}';
  var hash = 0x811c9dc5;
  for (final unit in '$userId-$dayKey'.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
  }
  final greeting = greetings[hash % greetings.length];
  return firstName == null
      ? greeting
      : greeting.replaceAll('{name}', firstName);
}
