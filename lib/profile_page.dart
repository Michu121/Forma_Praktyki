import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.points,
    required this.completedWorkouts,
    super.key,
  });

  final int points;
  final Set<DateTime> completedWorkouts;

  @override
  Widget build(BuildContext context) {
    final streak = _currentStreak();
    final hours = completedWorkouts.length * 0.9;
    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 29),
        Center(
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: appLime.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: appLime.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.person_rounded, size: 44, color: appLime),
              ),
              const SizedBox(height: 14),
              const Text(
                'Michał Nowak',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              const Text(
                'Twój profil treningowy',
                style: TextStyle(color: appMuted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            _profileStat('${completedWorkouts.length}', 'treningi'),
            const SizedBox(width: 10),
            _profileStat('${hours.toStringAsFixed(1)} h', 'na siłowni'),
            const SizedBox(width: 10),
            _profileStat('$streak dni', 'seria'),
          ],
        ),
        const SizedBox(height: 18),
        RankCard(points: points),
        const SizedBox(height: 16),
        WeeklyActivityChart(completedWorkouts: completedWorkouts),
        const SizedBox(height: 25),
        const SectionTitle('Twoje konto'),
        const SizedBox(height: 12),
        ProfileOption(
          icon: Icons.track_changes_rounded,
          title: 'Cele treningowe',
          subtitle: 'Zobacz swoje postępy',
          onTap: () => _showInfo(
            context,
            'Cele treningowe',
            'Twój cel to 4 treningi w tygodniu. Każdy ukończony trening dodaje 100 punktów.',
          ),
        ),
        ProfileOption(
          icon: Icons.sticky_note_2_outlined,
          title: 'Notatki',
          subtitle: 'Twoje notatki treningowe',
          onTap: () => _showInfo(
            context,
            'Notatki',
            'Notatka: pamiętaj o rozgrzewce barków i kontroluj tempo powtórzeń.',
          ),
        ),
        ProfileOption(
          icon: Icons.notifications_none_rounded,
          title: 'Powiadomienia',
          subtitle: 'Przypomnienia o treningu',
          onTap: () => _showInfo(
            context,
            'Powiadomienia',
            'Przypomnienia o dniach treningowych są włączone.',
          ),
        ),
        ProfileOption(
          icon: Icons.settings_outlined,
          title: 'Ustawienia',
          subtitle: 'Dane i preferencje',
          onTap: () => _showInfo(
            context,
            'Ustawienia',
            'Ustawienia profilu i preferencje treningowe.',
          ),
        ),
        const SizedBox(height: 18),
        NoteCard(
          onTap: () => _showInfo(
            context,
            'Notatka treningowa',
            'Pamiętaj o rozgrzewce barków. Spróbuj dziś 42,5 kg w ostatniej serii.',
          ),
        ),
      ],
    );
  }

  Widget _profileStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: appLime,
              ),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: appMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  int _currentStreak() {
    final today = dateOnly(DateTime.now());
    var cursor = completedWorkouts.any((date) => sameDate(date, today))
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (completedWorkouts.any((date) => sameDate(date, cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }
}
