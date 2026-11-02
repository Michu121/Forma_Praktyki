DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

const polishMonths = [
  'stycznia',
  'lutego',
  'marca',
  'kwietnia',
  'maja',
  'czerwca',
  'lipca',
  'sierpnia',
  'września',
  'października',
  'listopada',
  'grudnia',
];

const polishMonthNames = [
  'Styczeń',
  'Luty',
  'Marzec',
  'Kwiecień',
  'Maj',
  'Czerwiec',
  'Lipiec',
  'Sierpień',
  'Wrzesień',
  'Październik',
  'Listopad',
  'Grudzień',
];

const polishWeekdays = [
  'poniedziałek',
  'wtorek',
  'środa',
  'czwartek',
  'piątek',
  'sobota',
  'niedziela',
];

const shortWeekdays = ['P', 'W', 'Ś', 'C', 'P', 'S', 'N'];

String fullDateLabel(DateTime date) =>
    '${date.day} ${polishMonths[date.month - 1]} • ${polishWeekdays[date.weekday - 1]}';

String monthLabel(DateTime date) =>
    '${polishMonthNames[date.month - 1]} ${date.year}';

String dashboardDateLabel(DateTime date) =>
    '${polishWeekdays[date.weekday - 1].toUpperCase()}, ${date.day} ${polishMonths[date.month - 1].toUpperCase()}';

String shortDateLabel(DateTime date) =>
    '${date.day} ${polishMonths[date.month - 1]}';

String rankName(int points) {
  if (points >= 1600) return 'Mistrz';
  if (points >= 800) return 'Atleta';
  if (points >= 300) return 'Regularny';
  return 'Nowicjusz';
}

int nextRankPoints(int points) {
  if (points >= 1600) return 1600;
  if (points >= 800) return 1600;
  if (points >= 300) return 800;
  return 300;
}

int currentRankFloor(int points) {
  if (points >= 1600) return 1600;
  if (points >= 800) return 800;
  if (points >= 300) return 300;
  return 0;
}
