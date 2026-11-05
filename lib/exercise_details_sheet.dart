import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'workout_models.dart';

void showExerciseDetails(BuildContext context, String exerciseName) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExerciseDetailsSheet(exerciseName: exerciseName),
  );
}

class ExerciseDetailsSheet extends StatefulWidget {
  const ExerciseDetailsSheet({required this.exerciseName, super.key});

  final String exerciseName;

  @override
  State<ExerciseDetailsSheet> createState() => _ExerciseDetailsSheetState();
}

class _ExerciseDetailsSheetState extends State<ExerciseDetailsSheet> {
  int _completedSets = 0;
  bool _isSaved = false;
  bool _showingPreview = false;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final exercise = exerciseDatabase.firstWhere(
      (item) => item.name == widget.exerciseName,
      orElse: () => exerciseDatabase.first,
    );
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(
        21,
        12,
        21,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ĆWICZENIE',
                    style: TextStyle(
                      color: colors.accent,
                      letterSpacing: 0.8,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _isSaved ? 'Usuń z zapisanych' : 'Zapisz ćwiczenie',
                  onPressed: () => setState(() => _isSaved = !_isSaved),
                  icon: Icon(
                    _isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: _isSaved ? colors.accent : colors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              widget.exerciseName,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${exercise.muscleGroup} • ${exercise.equipment}\n'
              '${exercise.places.join(' / ')} • ${exercise.sets} serie • '
              '${exercise.reps} powtórzeń',
              style: TextStyle(color: colors.muted, fontSize: 12),
            ),
            const SizedBox(height: 19),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _showingPreview = !_showingPreview),
                child: Container(
                  height: 178,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.surfaceLight, colors.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 15,
                        top: 12,
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 125,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _showingPreview
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 35,
                          color: colors.background,
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        child: Text(
                          _showingPreview
                              ? 'Podgląd włączony'
                              : 'Podgląd techniki',
                          style: TextStyle(
                            color: colors.foreground.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 19),
            Text(
              'Jak wykonać?',
              style: TextStyle(
                color: colors.foreground,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 11),
            _Instruction(
              number: '01',
              text:
                  'Przygotuj sprzęt: ${exercise.equipment}. Zacznij w stabilnej pozycji.',
            ),
            const _Instruction(
              number: '02',
              text: 'Wykonuj ruch płynnie i kontroluj jego pełny, wygodny zakres.',
            ),
            const _Instruction(
              number: '03',
              text: 'Oddychaj regularnie i unikaj gwałtownych szarpnięć.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colors.accent,
                    size: 19,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Wskazówka: dobierz wariant do swoich możliwości. '
                      'Przerwij ćwiczenie, jeśli poczujesz ból.',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Serie: $_completedSets / ${exercise.sets}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (_completedSets < exercise.sets) {
                      setState(() => _completedSets++);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(
                    _completedSets == exercise.sets
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _completedSets == exercise.sets ? 'Gotowe' : 'Zapisz serię',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.background,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  const _Instruction({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              color: colors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.foreground.withValues(alpha: 0.8),
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
