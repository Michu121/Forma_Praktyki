import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({
    required this.isTodayCompleted,
    required this.onCompleteWorkout,
    super.key,
  });

  final bool isTodayCompleted;
  final VoidCallback onCompleteWorkout;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return AppPage(
      children: [
        const AppHeader(),
        const SizedBox(height: 27),
        const Text(
          'Twój plan',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Plan siłowy • 4 tygodnie',
          style: TextStyle(color: appMuted),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: appLime.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.bolt_rounded, color: appLime, size: 27),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budowanie siły', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Tydzień 3 z 4', style: TextStyle(color: appMuted, fontSize: 12)),
                  ],
                ),
              ),
              const Text('65%', style: TextStyle(color: appLime, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionTitle(
          '${_capitalize(polishWeekdays[today.weekday - 1])} • Góra ciała',
          trailing: '55 min',
        ),
        const SizedBox(height: 12),
        const ExerciseTile(
          title: 'Wyciskanie sztangi',
          subtitle: '4 serie  •  8–10 powt.',
          icon: Icons.fitness_center_rounded,
          number: 1,
        ),
        const ExerciseTile(
          title: 'Wiosłowanie hantlą',
          subtitle: '3 serie  •  10 powt. / str.',
          icon: Icons.sports_gymnastics_rounded,
          number: 2,
        ),
        const ExerciseTile(
          title: 'Wyciskanie żołnierskie',
          subtitle: '3 serie  •  8–10 powt.',
          icon: Icons.accessibility_new_rounded,
          number: 3,
        ),
        const ExerciseTile(
          title: 'Uginanie ramion',
          subtitle: '3 serie  •  12 powt.',
          icon: Icons.sports_handball_rounded,
          number: 4,
        ),
        const SizedBox(height: 8),
        WorkoutCard(
          completed: isTodayCompleted,
          onStart: () => _startWorkout(context),
          onOpenPlan: () => _startWorkout(context),
        ),
        const SizedBox(height: 16),
        NoteCard(onTap: () => _editNote(context)),
      ],
    );
  }

  void _startWorkout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TrainingSessionSheet(
        onComplete: () {
          Navigator.of(sheetContext).pop();
          onCompleteWorkout();
        },
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    final controller = TextEditingController(
      text: 'Pamiętaj o rozgrzewce barków. Spróbuj dziś 42,5 kg w ostatniej serii.',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notatka treningowa'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Dodaj notatkę'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notatka zapisana.')),
              );
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  String _capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}
