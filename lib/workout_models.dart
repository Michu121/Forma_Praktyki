import 'package:flutter/material.dart';

class Exercise {
  const Exercise({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.icon,
  });

  final String name;
  final String muscleGroup;
  final String equipment;
  final int sets;
  final String reps;
  final int restSeconds;
  final IconData icon;

  String get planSummary => '$sets serie • $reps powt.';
}

class WorkoutType {
  const WorkoutType({
    required this.name,
    required this.description,
    required this.icon,
    required this.exerciseNames,
  });

  final String name;
  final String description;
  final IconData icon;
  final List<String> exerciseNames;
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.name,
    required this.type,
    required this.exercises,
    this.restSeconds = 60,
    this.note = '',
  });

  final String name;
  final WorkoutType type;
  final List<Exercise> exercises;
  final int restSeconds;
  final String note;

  WorkoutPlan copyWith({String? name, String? note}) => WorkoutPlan(
    name: name ?? this.name,
    type: type,
    exercises: exercises,
    restSeconds: restSeconds,
    note: note ?? this.note,
  );

  int get estimatedMinutes =>
      exercises.fold<int>(
        0,
        (minutes, exercise) => minutes + exercise.sets * 2,
      ) +
      exercises.length * (restSeconds ~/ 60);
}

const exerciseDatabase = <Exercise>[
  Exercise(
    name: 'Wyciskanie sztangi',
    muscleGroup: 'Klatka piersiowa',
    equipment: 'Sztanga',
    sets: 4,
    reps: '8–10',
    restSeconds: 90,
    icon: Icons.fitness_center_rounded,
  ),
  Exercise(
    name: 'Wyciskanie hantli na skosie',
    muscleGroup: 'Klatka piersiowa',
    equipment: 'Hantle, ławka',
    sets: 3,
    reps: '10–12',
    restSeconds: 75,
    icon: Icons.fitness_center_rounded,
  ),
  Exercise(
    name: 'Rozpiętki na bramie',
    muscleGroup: 'Klatka piersiowa',
    equipment: 'Wyciąg',
    sets: 3,
    reps: '12–15',
    restSeconds: 60,
    icon: Icons.open_in_full_rounded,
  ),
  Exercise(
    name: 'Wiosłowanie hantlą',
    muscleGroup: 'Plecy',
    equipment: 'Hantla',
    sets: 3,
    reps: '10 / str.',
    restSeconds: 75,
    icon: Icons.sports_gymnastics_rounded,
  ),
  Exercise(
    name: 'Ściąganie drążka wyciągu',
    muscleGroup: 'Plecy',
    equipment: 'Wyciąg',
    sets: 4,
    reps: '10–12',
    restSeconds: 75,
    icon: Icons.vertical_align_bottom_rounded,
  ),
  Exercise(
    name: 'Wyciskanie żołnierskie',
    muscleGroup: 'Barki',
    equipment: 'Sztanga',
    sets: 3,
    reps: '8–10',
    restSeconds: 75,
    icon: Icons.accessibility_new_rounded,
  ),
  Exercise(
    name: 'Unoszenie hantli bokiem',
    muscleGroup: 'Barki',
    equipment: 'Hantle',
    sets: 3,
    reps: '12–15',
    restSeconds: 60,
    icon: Icons.pan_tool_alt_rounded,
  ),
  Exercise(
    name: 'Uginanie ramion',
    muscleGroup: 'Biceps',
    equipment: 'Hantle',
    sets: 3,
    reps: '12',
    restSeconds: 60,
    icon: Icons.sports_handball_rounded,
  ),
  Exercise(
    name: 'Prostowanie ramion na wyciągu',
    muscleGroup: 'Triceps',
    equipment: 'Wyciąg',
    sets: 3,
    reps: '12',
    restSeconds: 60,
    icon: Icons.sports_martial_arts_rounded,
  ),
  Exercise(
    name: 'Przysiad ze sztangą',
    muscleGroup: 'Nogi',
    equipment: 'Sztanga',
    sets: 4,
    reps: '6–8',
    restSeconds: 120,
    icon: Icons.fitness_center_rounded,
  ),
  Exercise(
    name: 'Martwy ciąg rumuński',
    muscleGroup: 'Tył uda',
    equipment: 'Sztanga',
    sets: 3,
    reps: '8–10',
    restSeconds: 90,
    icon: Icons.fitness_center_rounded,
  ),
  Exercise(
    name: 'Wykroki z hantlami',
    muscleGroup: 'Nogi',
    equipment: 'Hantle',
    sets: 3,
    reps: '10 / str.',
    restSeconds: 75,
    icon: Icons.directions_walk_rounded,
  ),
  Exercise(
    name: 'Wspięcia na palce',
    muscleGroup: 'Łydki',
    equipment: 'Masa ciała',
    sets: 3,
    reps: '15',
    restSeconds: 45,
    icon: Icons.trending_up_rounded,
  ),
  Exercise(
    name: 'Deska',
    muscleGroup: 'Brzuch',
    equipment: 'Masa ciała',
    sets: 3,
    reps: '30–45 s',
    restSeconds: 45,
    icon: Icons.accessibility_rounded,
  ),
  Exercise(
    name: 'Bieg na bieżni',
    muscleGroup: 'Kondycja',
    equipment: 'Bieżnia',
    sets: 1,
    reps: '20 min',
    restSeconds: 30,
    icon: Icons.directions_run_rounded,
  ),
  Exercise(
    name: 'Jazda na rowerze',
    muscleGroup: 'Kondycja',
    equipment: 'Rower',
    sets: 1,
    reps: '25 min',
    restSeconds: 30,
    icon: Icons.pedal_bike_rounded,
  ),
];

final workoutTypes = <WorkoutType>[
  WorkoutType(
    name: 'Góra ciała',
    description: 'Klatka, plecy, barki i ramiona',
    icon: Icons.accessibility_new_rounded,
    exerciseNames: [
      'Wyciskanie sztangi',
      'Wiosłowanie hantlą',
      'Wyciskanie żołnierskie',
      'Uginanie ramion',
    ],
  ),
  WorkoutType(
    name: 'Dół ciała',
    description: 'Nogi, pośladki i łydki',
    icon: Icons.directions_run_rounded,
    exerciseNames: [
      'Przysiad ze sztangą',
      'Martwy ciąg rumuński',
      'Wykroki z hantlami',
      'Wspięcia na palce',
    ],
  ),
  WorkoutType(
    name: 'Całe ciało',
    description: 'Kompleksowy trening całego ciała',
    icon: Icons.bolt_rounded,
    exerciseNames: [
      'Przysiad ze sztangą',
      'Wyciskanie sztangi',
      'Wiosłowanie hantlą',
      'Deska',
    ],
  ),
  WorkoutType(
    name: 'Push',
    description: 'Klatka piersiowa, barki i triceps',
    icon: Icons.arrow_upward_rounded,
    exerciseNames: [
      'Wyciskanie sztangi',
      'Wyciskanie hantli na skosie',
      'Unoszenie hantli bokiem',
      'Prostowanie ramion na wyciągu',
    ],
  ),
  WorkoutType(
    name: 'Pull',
    description: 'Plecy i biceps',
    icon: Icons.arrow_downward_rounded,
    exerciseNames: [
      'Ściąganie drążka wyciągu',
      'Wiosłowanie hantlą',
      'Uginanie ramion',
    ],
  ),
  WorkoutType(
    name: 'Kondycja',
    description: 'Trening cardio i wytrzymałość',
    icon: Icons.favorite_border_rounded,
    exerciseNames: ['Bieg na bieżni', 'Jazda na rowerze', 'Deska'],
  ),
];

WorkoutPlan planForType(WorkoutType type) => WorkoutPlan(
  name: type.name,
  type: type,
  exercises: type.exerciseNames
      .map(
        (name) =>
            exerciseDatabase.firstWhere((exercise) => exercise.name == name),
      )
      .toList(),
);
