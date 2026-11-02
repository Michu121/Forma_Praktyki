import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'date_helpers.dart';
import 'workout_models.dart';

class WorkoutDataSnapshot {
  const WorkoutDataSnapshot({
    required this.templates,
    required this.scheduledWorkouts,
    required this.dayNotes,
  });

  final List<WorkoutPlan> templates;
  final Map<DateTime, WorkoutPlan> scheduledWorkouts;
  final Map<DateTime, String> dayNotes;
}

class WorkoutDataStore {
  static const _key = 'workoutData.v1';

  Future<WorkoutDataSnapshot?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return null;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final templates = (data['templates'] as List<dynamic>)
        .map((item) => _decodeWorkout(item as Map<String, dynamic>))
        .toList();
    final scheduled = <DateTime, WorkoutPlan>{};
    for (final entry in (data['scheduled'] as Map<String, dynamic>).entries) {
      scheduled[dateOnly(DateTime.parse(entry.key))] = _decodeWorkout(
        entry.value as Map<String, dynamic>,
      );
    }
    final notes = <DateTime, String>{};
    for (final entry in (data['notes'] as Map<String, dynamic>).entries) {
      notes[dateOnly(DateTime.parse(entry.key))] = entry.value as String;
    }
    return WorkoutDataSnapshot(
      templates: templates,
      scheduledWorkouts: scheduled,
      dayNotes: notes,
    );
  }

  Future<void> save({
    required List<WorkoutPlan> templates,
    required Map<DateTime, WorkoutPlan> scheduledWorkouts,
    required Map<DateTime, String> dayNotes,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _key,
      jsonEncode({
        'templates': templates.map(_encodeWorkout).toList(),
        'scheduled': {
          for (final entry in scheduledWorkouts.entries)
            _dateKey(entry.key): _encodeWorkout(entry.value),
        },
        'notes': {
          for (final entry in dayNotes.entries)
            _dateKey(entry.key): entry.value,
        },
      }),
    );
    if (!saved) throw StateError('Nie udało się zapisać planów treningowych.');
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static Map<String, Object> _encodeWorkout(WorkoutPlan plan) => {
    'name': plan.name,
    'type': plan.type.name,
    'description': plan.type.description,
    'exercises': plan.exercises.map((exercise) => exercise.name).toList(),
    'restSeconds': plan.restSeconds,
    'note': plan.note,
  };

  static WorkoutPlan _decodeWorkout(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final knownType = workoutTypes.where((type) => type.name == typeName);
    final type = knownType.isNotEmpty
        ? knownType.first
        : WorkoutType(
            name: typeName,
            description: json['description'] as String? ?? '',
            icon: Icons.fitness_center_rounded,
            exerciseNames: const [],
          );
    final exercises = (json['exercises'] as List<dynamic>)
        .map(
          (name) =>
              exerciseDatabase.firstWhere((exercise) => exercise.name == name),
        )
        .toList();
    return WorkoutPlan(
      name: json['name'] as String,
      type: type,
      exercises: exercises,
      restSeconds: json['restSeconds'] as int? ?? 60,
      note: json['note'] as String? ?? '',
    );
  }
}
