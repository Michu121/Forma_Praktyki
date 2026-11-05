import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'date_helpers.dart';
import 'rest_notification_service.dart';
import 'training_session_sheet.dart';
import 'welcome_message.dart';
import 'workout_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.today,
    required this.nextWorkout,
    required this.nextWorkoutDate,
    required this.points,
    required this.completedWorkouts,
    required this.weeklyWorkoutGoal,
    required this.userId,
    required this.userName,
    required this.workout,
    required this.isTodayCompleted,
    required this.onCompleteWorkout,
    required this.onOpenPlan,
    required this.onOpenCalendar,
    required this.onOpenProfile,
    required this.defaultRestSeconds,
    required this.restNotifications,
    super.key,
  });

  final DateTime today;
  final WorkoutPlan? nextWorkout;
  final DateTime? nextWorkoutDate;
  final int points;
  final Set<DateTime> completedWorkouts;
  final int weeklyWorkoutGoal;
  final String userId;
  final String? userName;
  final WorkoutPlan workout;
  final bool isTodayCompleted;
  final VoidCallback onCompleteWorkout;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenProfile;
  final int defaultRestSeconds;
  final RestNotificationController restNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AppPage(
      children: [
        AppHeader(showAvatar: true, onAvatarTap: onOpenProfile),
        const SizedBox(height: 22),
        Text(
          dashboardDateLabel(today),
          style: TextStyle(
            color: colors.muted,
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        KeyedSubtree(
          key: const Key('daily_welcome_message'),
          child: AppPageTitle(
            dailyWelcomeMessage(
              userId: userId,
              date: today,
              userName: userName,
            ),
          ),
        ),
        const SizedBox(height: 17),
        RankCard(points: points),
        const SizedBox(height: 14),
        WeeklyWorkoutGoalCard(
          completed: workoutsCompletedThisWeek(completedWorkouts, today),
          goal: weeklyWorkoutGoal,
        ),
        const SizedBox(height: 25),
        SectionTitle(
          'Twój dzisiejszy plan',
          trailing: '${workout.exercises.length} ćwiczeń',
        ),
        const SizedBox(height: 12),
        WorkoutCard(
          workout: workout,
          completed: isTodayCompleted,
          onStart: () => _startWorkout(context),
          onOpenPlan: onOpenPlan,
        ),
        const SizedBox(height: 25),
        SectionTitle(
          'Następny trening',
          trailing: nextWorkoutDate == null
              ? 'Brak planu'
              : shortDateLabel(nextWorkoutDate!),
        ),
        const SizedBox(height: 12),
        _NextWorkoutCard(
          workout: nextWorkout,
          date: nextWorkoutDate,
          onTap: onOpenCalendar,
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
        workout: workout,
        restNotifications: restNotifications,
        onComplete: () {
          Navigator.of(sheetContext).pop();
          onCompleteWorkout();
        },
      ),
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  const _NextWorkoutCard({
    required this.workout,
    required this.date,
    required this.onTap,
  });

  final WorkoutPlan? workout;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(appCardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(appCardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  workout?.type.icon ?? Icons.calendar_month_rounded,
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout?.name ?? 'Brak zaplanowanego treningu',
                      style: TextStyle(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout == null
                          ? 'Dotknij, aby otworzyć kalendarz'
                          : '${workout!.exercises.length} ćwiczeń • ${shortDateLabel(date!)}',
                      style: TextStyle(color: colors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
