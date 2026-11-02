import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.today,
    required this.points,
    required this.completedWorkouts,
    required this.isTodayCompleted,
    required this.onCompleteWorkout,
    required this.onOpenPlan,
    required this.onOpenCalendar,
    super.key,
  });

  final DateTime today;
  final int points;
  final Set<DateTime> completedWorkouts;
  final bool isTodayCompleted;
  final VoidCallback onCompleteWorkout;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final nextWorkout = today.add(Duration(days: today.weekday == 5 ? 3 : 1));

    return AppPage(
      children: [
        const AppHeader(showAvatar: true),
        const SizedBox(height: 27),
        Text(
          dashboardDateLabel(today),
          style: const TextStyle(
            color: appMuted,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Gotowy na\nmocny trening?',
          style: TextStyle(fontSize: 31, height: 1.12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        RankCard(points: points),
        const SizedBox(height: 25),
        const SectionTitle('Twój dzisiejszy plan', trailing: '4 ćwiczenia'),
        const SizedBox(height: 12),
        WorkoutCard(
          completed: isTodayCompleted,
          onStart: () => _startWorkout(context),
          onOpenPlan: onOpenPlan,
        ),
        const SizedBox(height: 25),
        SectionTitle(
          'Następny trening',
          trailing:
              '${polishWeekdays[nextWorkout.weekday - 1][0].toUpperCase()}${polishWeekdays[nextWorkout.weekday - 1].substring(1)}, ${shortDateLabel(nextWorkout)}',
        ),
        const SizedBox(height: 12),
        Material(
          color: appSurface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onOpenCalendar,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      color: const Color(0xFF302A21),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Color(0xFFF0B86A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dół ciała', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text(
                          'Nogi • pośladki  ·  50 min',
                          style: TextStyle(color: appMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: appMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        WeeklyActivityChart(completedWorkouts: completedWorkouts),
        const SizedBox(height: 22),
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
}
