import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'rest_duration_picker.dart';
import 'workout_models.dart';

Future<WorkoutPlan?> showWorkoutBuilder(
  BuildContext context, {
  int defaultRestSeconds = 60,
}) => showModalBottomSheet<WorkoutPlan>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => WorkoutBuilderSheet(defaultRestSeconds: defaultRestSeconds),
);

class WorkoutBuilderSheet extends StatefulWidget {
  const WorkoutBuilderSheet({this.defaultRestSeconds = 60, super.key});

  final int defaultRestSeconds;

  @override
  State<WorkoutBuilderSheet> createState() => _WorkoutBuilderSheetState();
}

class _WorkoutBuilderSheetState extends State<WorkoutBuilderSheet> {
  late final TextEditingController _nameController;
  late WorkoutType _selectedType;
  late Set<String> _selectedExercises;
  late int _restSeconds;
  String _searchQuery = '';
  String _selectedPlace = 'Wszystkie';
  String _selectedMuscleGroup = 'Wszystkie';
  String _selectedEquipment = 'Wszystkie';

  @override
  void initState() {
    super.initState();
    _selectedType = workoutTypes.first;
    _selectedExercises = _selectedType.exerciseNames.toSet();
    _restSeconds = widget.defaultRestSeconds;
    _nameController = TextEditingController(text: _selectedType.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final muscleGroups =
        exerciseDatabase
            .map((exercise) => exercise.muscleGroup)
            .toSet()
            .toList()
          ..sort();
    const equipmentCategories = [
      'Bez sprzętu',
      'Masa ciała',
      'Hantle',
      'Hantla',
      'Sztanga',
      'Guma oporowa',
      'Drążek',
      'Wyciąg',
      'Maszyna',
      'Suwnica',
      'Kettlebell',
      'Bieżnia',
      'Rower',
      'Skakanka',
      'Ławka',
      'Podwyższenie',
      'Poręcze',
    ];
    final filteredExercises = exerciseDatabase
        .where(
          (exercise) =>
              (_searchQuery.isEmpty ||
                  exercise.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  exercise.muscleGroup.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  exercise.equipment.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  )) &&
              (_selectedPlace == 'Wszystkie' ||
                  exercise.places.contains(_selectedPlace)) &&
              (_selectedMuscleGroup == 'Wszystkie' ||
                  exercise.muscleGroup == _selectedMuscleGroup) &&
              (_selectedEquipment == 'Wszystkie' ||
                  (_selectedEquipment == 'Hantle' ||
                          _selectedEquipment == 'Hantla'
                      ? exercise.equipment.toLowerCase().contains('hantl')
                      : exercise.equipment.toLowerCase().contains(
                          _selectedEquipment.toLowerCase(),
                        ))),
        )
        .toList();
    final exercises = filteredExercises;

    return SafeArea(
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
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
                    const SizedBox(height: 18),
                    Text(
                      'Utwórz schemat treningu',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nadaj nazwę, wybierz typ i ćwiczenia.',
                      style: TextStyle(color: colors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 43,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: workoutTypes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final type = workoutTypes[index];
                          return ChoiceChip(
                            avatar: Icon(type.icon, size: 17),
                            label: Text(type.name),
                            selected: _selectedType == type,
                            onSelected: (_) => setState(() {
                              _selectedType = type;
                              _selectedExercises = type.exerciseNames.toSet();
                              _nameController.text = type.name;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Nazwa schematu',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedType.description,
                      style: TextStyle(color: colors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.muted.withValues(alpha: 0.15)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Szukaj w bazie ćwiczeń',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ExerciseFilterDropdown(
                                  label: 'Miejsce',
                                  value: _selectedPlace,
                                  options: const [
                                    'Wszystkie',
                                    'Dom',
                                    'Siłownia',
                                    'Na zewnątrz',
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _selectedPlace = value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ExerciseFilterDropdown(
                                  label: 'Partia mięśni',
                                  value: _selectedMuscleGroup,
                                  options: ['Wszystkie', ...muscleGroups],
                                  onChanged: (value) => setState(
                                    () => _selectedMuscleGroup = value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _ExerciseFilterDropdown(
                            label: 'Sprzęt',
                            value: _selectedEquipment,
                            options: ['Wszystkie', ...equipmentCategories],
                            onChanged: (value) =>
                                setState(() => _selectedEquipment = value),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Znaleziono: ${filteredExercises.length} ćwiczeń',
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exercises.isEmpty)
                      const ListTile(title: Text('Nie znaleziono ćwiczeń.')),
                    for (final exercise in exercises)
                      Material(
                        color: colors.surface,
                        child: CheckboxListTile(
                          value: _selectedExercises.contains(exercise.name),
                          onChanged: (selected) => setState(() {
                            if (selected == true) {
                              _selectedExercises.add(exercise.name);
                            } else {
                              _selectedExercises.remove(exercise.name);
                            }
                          }),
                          activeColor: colors.accent,
                          title: Text(
                            exercise.name,
                            style: TextStyle(
                              color: colors.foreground,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${exercise.muscleGroup} • ${exercise.equipment}\n'
                            '${exercise.places.join(' / ')} • ${exercise.planSummary}',
                            style: TextStyle(color: colors.muted, fontSize: 10),
                          ),
                          secondary: Icon(exercise.icon, color: colors.accent),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RestDurationPicker(
                        title: 'Przerwa między seriami',
                        seconds: _restSeconds,
                        onChanged: (value) =>
                            setState(() => _restSeconds = value),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _selectedExercises.isEmpty ||
                            _nameController.text.trim().isEmpty
                        ? null
                        : () {
                            final selected = exerciseDatabase
                                .where(
                                  (exercise) => _selectedExercises.contains(
                                    exercise.name,
                                  ),
                                )
                                .toList();
                            Navigator.pop(
                              context,
                              WorkoutPlan(
                                name: _nameController.text.trim(),
                                type: _selectedType,
                                exercises: selected,
                                restSeconds: _restSeconds,
                              ),
                            );
                          },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      'Zapisz schemat (${_selectedExercises.length} ćw.)',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.foreground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseFilterDropdown extends StatelessWidget {
  const _ExerciseFilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    ),
    items: [
      for (final option in options)
        DropdownMenuItem(value: option, child: Text(option)),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}
