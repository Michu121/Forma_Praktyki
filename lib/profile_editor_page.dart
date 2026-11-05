import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_colors.dart';
import 'user_profile.dart';

class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<ProfileEditorPage> createState() => _ProfileEditorPageState();
}

class _ProfileEditorPageState extends State<ProfileEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _waterTargetController;
  late DateTime? _birthDate;
  late ReferenceSex _sex;
  late String? _avatarPath;
  late bool _clearAvatar;
  late bool _customWaterTarget;
  late bool _waterReminderEnabled;
  late TimeOfDay _waterReminderTime;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _nicknameController = TextEditingController(text: profile.nickname);
    _heightController = TextEditingController(
      text: profile.heightCm?.toStringAsFixed(0) ?? '',
    );
    _weightController = TextEditingController(
      text: profile.weightKg?.toStringAsFixed(1) ?? '',
    );
    _waterTargetController = TextEditingController(
      text: profile.waterTargetOverrideMl?.toString() ?? '',
    );
    _birthDate = profile.birthDate;
    _sex = profile.sex;
    _avatarPath = profile.avatarPath;
    _clearAvatar = false;
    _customWaterTarget = profile.waterTargetOverrideMl != null;
    _waterReminderEnabled = profile.waterReminderEnabled;
    _waterReminderTime = TimeOfDay(
      hour: profile.waterReminderHour,
      minute: profile.waterReminderMinute,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waterTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final estimateProfile = widget.profile.copyWith(
      sex: _sex,
      birthDate: _birthDate,
      clearBirthDate: _birthDate == null,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj profil'),
        backgroundColor: colors.background,
        actions: [TextButton(onPressed: _save, child: const Text('Zapisz'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colors.surfaceLight,
                    foregroundImage: _avatarPath == null
                        ? null
                        : FileImage(File(_avatarPath!)),
                    child: _avatarPath == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: colors.accent,
                          )
                        : null,
                  ),
                  TextButton.icon(
                    onPressed: _chooseAvatar,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Wybierz zdjęcie profilowe'),
                  ),
                  if (_avatarPath != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _avatarPath = null;
                        _clearAvatar = true;
                      }),
                      child: const Text('Usuń zdjęcie'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Imię'),
              validator: _requiredName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nazwisko'),
              validator: _requiredName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nicknameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Pseudonim',
                helperText:
                    'Jeśli go ustawisz, będzie wyświetlany zamiast imienia.',
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Data urodzenia'),
              subtitle: Text(
                _birthDate == null
                    ? 'Nie ustawiono'
                    : '${_birthDate!.day.toString().padLeft(2, '0')}.'
                          '${_birthDate!.month.toString().padLeft(2, '0')}.'
                          '${_birthDate!.year}'
                          ' • ${estimateProfile.ageAt(DateTime.now())} lat',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _chooseBirthDate,
            ),
            DropdownButtonFormField<ReferenceSex>(
              initialValue: _sex,
              decoration: const InputDecoration(
                labelText: 'Kategoria referencyjna do celu wody',
              ),
              items: const [
                DropdownMenuItem(
                  value: ReferenceSex.female,
                  child: Text('Kobieta'),
                ),
                DropdownMenuItem(
                  value: ReferenceSex.male,
                  child: Text('Mężczyzna'),
                ),
                DropdownMenuItem(
                  value: ReferenceSex.unspecified,
                  child: Text('Nie podaję'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sex = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _measurementField(
                    controller: _heightController,
                    label: 'Wzrost',
                    suffix: 'cm',
                    minimum: 80,
                    maximum: 250,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _measurementField(
                    controller: _weightController,
                    label: 'Masa ciała',
                    suffix: 'kg',
                    minimum: 20,
                    maximum: 400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Nawodnienie',
              style: TextStyle(
                color: colors.foreground,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Orientacyjna wartość referencyjna EFSA: '
              '${estimateProfile.suggestedWaterTargetMl} ml całkowitej wody '
              'dziennie. Wzrost i masa są zapisywane w profilu, ale źródła '
              'nie potwierdzają przeliczania tej wartości na ich podstawie.',
              style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ustaw własny cel wody'),
              value: _customWaterTarget,
              onChanged: (value) => setState(() => _customWaterTarget = value),
            ),
            if (_customWaterTarget)
              TextFormField(
                controller: _waterTargetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Własny cel całkowitej wody',
                  suffixText: 'ml/dzień',
                ),
                validator: _validateWaterTarget,
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Codzienne przypomnienie o wodzie'),
              value: _waterReminderEnabled,
              onChanged: (value) =>
                  setState(() => _waterReminderEnabled = value),
            ),
            if (_waterReminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Godzina przypomnienia'),
                subtitle: Text(_waterReminderTime.format(context)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _chooseReminderTime,
              ),
            const SizedBox(height: 12),
            Text(
              'Cel EFSA oznacza całkowitą wodę z napojów i żywności. '
              'Zapisywana niżej ilość dotyczy wypitych napojów.',
              style: TextStyle(color: colors.muted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measurementField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required double minimum,
    required double maximum,
  }) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return null;
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed == null ||
          !parsed.isFinite ||
          parsed < minimum ||
          parsed > maximum) {
        return 'Wpisz wartość od $minimum do $maximum.';
      }
      return null;
    },
  );

  String? _requiredName(String? value) =>
      value == null || value.trim().isEmpty ? 'To pole jest wymagane.' : null;

  String? _validateWaterTarget(String? value) {
    if (!_customWaterTarget) return null;
    final target = int.tryParse(value ?? '');
    if (target == null || target < 500 || target > 10000) {
      return 'Wpisz wartość od 500 do 10 000 ml.';
    }
    return null;
  }

  Future<void> _chooseBirthDate() async {
    final today = DateTime.now();
    final currentDate = _birthDate;
    final date = await showDatePicker(
      context: context,
      initialDate:
          currentDate ?? DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(today.year - 120),
      lastDate: today,
      helpText: 'Data urodzenia',
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _chooseReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _waterReminderTime,
      helpText: 'Godzina przypomnienia o wodzie',
    );
    if (time != null) setState(() => _waterReminderTime = time);
  }

  Future<void> _chooseAvatar() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final extension = p.extension(image.path);
      final destination = p.join(
        directory.path,
        'profile-avatar-${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      await File(image.path).copy(destination);
      if (mounted) {
        setState(() {
          _avatarPath = destination;
          _clearAvatar = false;
        });
      }
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wybrać zdjęcia: $error')),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final height = _parseMeasurement(_heightController.text);
    final weight = _parseMeasurement(_weightController.text);
    final target = _customWaterTarget
        ? int.parse(_waterTargetController.text)
        : null;
    final updatedProfile = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      birthDate: _birthDate,
      clearBirthDate: _birthDate == null,
      sex: _sex,
      heightCm: height,
      clearHeight: height == null,
      weightKg: weight,
      clearWeight: weight == null,
      avatarPath: _avatarPath,
      clearAvatar: _clearAvatar,
      waterTargetOverrideMl: target,
      clearWaterTargetOverride: target == null,
      waterReminderEnabled: _waterReminderEnabled,
      waterReminderHour: _waterReminderTime.hour,
      waterReminderMinute: _waterReminderTime.minute,
    );
    Navigator.pop(context, updatedProfile);
  }

  double? _parseMeasurement(String value) =>
      value.trim().isEmpty ? null : double.parse(value.replaceAll(',', '.'));
}
