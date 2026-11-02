import 'dart:async';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'date_helpers.dart';
import 'exercise_details_sheet.dart';
import 'workout_models.dart';

class TrainingSessionSheet extends StatefulWidget {
  const TrainingSessionSheet({
    required this.workout,
    required this.onComplete,
    super.key,
  });

  final WorkoutPlan workout;
  final VoidCallback onComplete;

  @override
  State<TrainingSessionSheet> createState() => _TrainingSessionSheetState();
}

class _TrainingSessionSheetState extends State<TrainingSessionSheet> {
  final Map<String, int> _completedSets = {};
  Timer? _timer;
  int _exerciseIndex = 0;
  int _remainingSeconds = 0;
  bool _isResting = false;
  bool _isFinished = false;

  Exercise get _exercise => widget.workout.exercises[_exerciseIndex];

  int get _setsForExercise => _completedSets[_exercise.name] ?? 0;

  int get _totalSets => widget.workout.exercises.fold<int>(
    0,
    (total, exercise) => total + exercise.sets,
  );

  int get _doneSets => _completedSets.values.fold<int>(0, (a, b) => a + b);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final progress = _totalSets == 0 ? 1.0 : _doneSets / _totalSets;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
                    color: colors.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workout.name,
                          style: TextStyle(
                            color: colors.foreground,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isFinished
                              ? 'Wszystkie ćwiczenia wykonane'
                              : 'Ćwiczenie ${_exerciseIndex + 1} z ${widget.workout.exercises.length}',
                          style: TextStyle(color: colors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zamknij trening',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: colors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: colors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
              const SizedBox(height: 18),
              if (!_isFinished) ...[
                Material(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => showExerciseDetails(context, _exercise.name),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(_exercise.icon, color: colors.accent),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _exercise.name,
                                  style: TextStyle(
                                    color: colors.foreground,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_exercise.muscleGroup} • ${_exercise.planSummary}',
                                  style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.info_outline_rounded, color: colors.muted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      Text(
                        _isResting ? 'PRZERWA' : 'SERIE',
                        style: TextStyle(
                          color: colors.muted,
                          letterSpacing: 1.6,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isResting
                            ? _formatTime(_remainingSeconds)
                            : '$_setsForExercise / ${_exercise.sets}',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isResting
                            ? 'Odpocznij. Następna seria lub ćwiczenie za chwilę.'
                            : 'Łącznie: $_doneSets / $_totalSets serii',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                if (_isResting)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _advanceAfterRest,
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Pomiń przerwę'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _recordSet,
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Zapisz serię ${_setsForExercise + 1}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.foreground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ] else ...[
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: colors.accent,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Świetna robota!',
                    style: TextStyle(
                      color: colors.foreground,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    '${widget.workout.exercises.length} ćwiczenia • $_totalSets serii',
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onComplete,
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('Zakończ i odbierz 100 pkt'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '${shortDateLabel(DateTime.now())} • przerwa ${widget.workout.restSeconds} s',
                style: TextStyle(color: colors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recordSet() {
    setState(() {
      _completedSets[_exercise.name] = _setsForExercise + 1;
      _isResting = true;
      _remainingSeconds = widget.workout.restSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _advanceAfterRest();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _advanceAfterRest() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _isResting = false;
      _remainingSeconds = 0;
      if (_setsForExercise >= _exercise.sets) {
        if (_exerciseIndex + 1 >= widget.workout.exercises.length) {
          _isFinished = true;
        } else {
          _exerciseIndex++;
        }
      }
    });
  }

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
