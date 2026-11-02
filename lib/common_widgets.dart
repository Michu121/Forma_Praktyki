import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'date_helpers.dart';
import 'exercise_details_sheet.dart';
import 'workout_models.dart';

class AppPage extends StatelessWidget {
  const AppPage({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({this.showAvatar = false, super.key});

  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: colors.background,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FORMA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        if (showAvatar) ...[
          IconButton(
            tooltip: 'Powiadomienia',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nie masz nowych powiadomień.')),
            ),
            icon: Icon(Icons.notifications_none_rounded, color: colors.muted),
          ),
          const SizedBox(width: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.person_rounded, size: 21, color: colors.accent),
          ),
        ] else
          Text(
            monthLabel(DateTime.now()).toUpperCase(),
            style: TextStyle(
              color: colors.muted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: TextStyle(color: colors.muted, fontSize: 11)),
      ],
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Material(
      color: colors.surfaceLight,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: colors.foreground.withValues(alpha: 0.75),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.completed,
    required this.workout,
    required this.onStart,
    required this.onOpenPlan,
    this.isCalendar = false,
    super.key,
  });

  final bool completed;
  final WorkoutPlan workout;
  final bool isCalendar;
  final VoidCallback onStart;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WorkoutTag(workout.name.toUpperCase()),
              const Spacer(),
              Icon(Icons.schedule_rounded, size: 15, color: colors.muted),
              const SizedBox(width: 5),
              Text(
                '${workout.estimatedMinutes} min',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            workout.name,
            style: TextStyle(
              color: colors.foreground,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${workout.exercises.length} ćwiczeń • przerwa ${workout.restSeconds} s',
            style: TextStyle(color: colors.muted, fontSize: 12),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: completed ? null : onStart,
                  icon: Icon(
                    completed
                        ? Icons.check_circle_outline_rounded
                        : (isCalendar
                              ? Icons.play_arrow_rounded
                              : Icons.fitness_center_rounded),
                    size: 19,
                  ),
                  label: Text(
                    completed
                        ? 'Trening zaliczony'
                        : (isCalendar ? 'Wykonaj trening' : 'Zacznij trening'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    disabledBackgroundColor: colors.accent.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: colors.foreground,
                    disabledForegroundColor: colors.foreground.withValues(
                      alpha: 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              RoundIconButton(
                icon: Icons.more_horiz_rounded,
                onTap: onOpenPlan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({required this.completedWorkouts, super.key});

  final Set<DateTime> completedWorkouts;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final today = dateOnly(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekDates = List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );
    final weeklyCount = weekDates
        .where(
          (date) =>
              completedWorkouts.any((completed) => sameDate(date, completed)),
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.035)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Aktywność w tym tygodniu',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$weeklyCount treningów',
                style: TextStyle(color: colors.accent, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekDates.length, (index) {
                final date = weekDates[index];
                final trained = completedWorkouts.any(
                  (completed) => sameDate(date, completed),
                );
                final isToday = sameDate(date, today);
                return Expanded(
                  child: Semantics(
                    label:
                        '${shortDateLabel(date)}${trained ? ', trening wykonany' : ''}',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          trained ? '100' : '',
                          style: TextStyle(
                            color: colors.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 20,
                          height: trained ? 48 : (isToday ? 12 : 5),
                          decoration: BoxDecoration(
                            color: trained
                                ? colors.accent
                                : (isToday
                                      ? colors.accent.withValues(alpha: 0.4)
                                      : colors.surfaceLight),
                            borderRadius: BorderRadius.circular(8),
                            border: isToday && !trained
                                ? Border.all(
                                    color: colors.accent.withValues(alpha: 0.5),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shortWeekdays[index],
                          style: TextStyle(
                            color: isToday ? colors.foreground : colors.muted,
                            fontSize: 10,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class RankCard extends StatelessWidget {
  const RankCard({required this.points, super.key});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final next = nextRankPoints(points);
    final floor = currentRankFloor(points);
    final progress = next == floor
        ? 1.0
        : ((points - floor) / (next - floor)).clamp(0.0, 1.0);
    final pointsToNext = (next - points).clamp(0, next);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.military_tech_rounded, color: colors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ranga: ${rankName(points)}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$points pkt • 100 pkt za trening',
                      style: TextStyle(color: colors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.stars_rounded, color: colors.accent, size: 25),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pointsToNext == 0
                ? 'Maksymalna ranga osiągnięta!'
                : 'Jeszcze $pointsToNext pkt do rangi ${_nextRankName(points)}',
            style: TextStyle(color: colors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _nextRankName(int value) {
    if (value >= 1600) return 'Mistrz';
    if (value >= 800) return 'Mistrz';
    if (value >= 300) return 'Atleta';
    return 'Regularny';
  }
}

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.number,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => showExerciseDetails(context, title),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: colors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.accent, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(color: colors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Color(0xFF616960),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.muted,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  const ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: colors.accent, size: 21),
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: colors.muted, fontSize: 11),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.muted,
            size: 19,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({required this.note, required this.onTap, super.key});

  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: colors.muted.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                color: colors.accent,
                size: 20,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Twoja notatka',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      note.isEmpty ? 'Dotknij, aby dodać notatkę.' : note,
                      style: TextStyle(
                        color: colors.muted,
                        height: 1.45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, color: colors.muted, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutTag extends StatelessWidget {
  const _WorkoutTag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.accent,
          letterSpacing: 0.8,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
