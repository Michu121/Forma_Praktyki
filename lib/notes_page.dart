import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';
import 'personal_note.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({
    required this.notes,
    required this.onSaveNote,
    required this.onDeleteNote,
    super.key,
  });

  final List<PersonalNote> notes;
  final Future<void> Function(PersonalNote note) onSaveNote;
  final Future<void> Function(PersonalNote note) onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    final sortedNotes = [...notes]
      ..sort((first, second) {
        final firstReminder = first.reminderAt;
        final secondReminder = second.reminderAt;
        if (firstReminder == null && secondReminder != null) return 1;
        if (firstReminder != null && secondReminder == null) return -1;
        if (firstReminder != null && secondReminder != null) {
          final comparison = firstReminder.compareTo(secondReminder);
          if (comparison != 0) return comparison;
        }
        return second.id.compareTo(first.id);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notatki'),
        backgroundColor: colors.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editNote(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Dodaj notatkę'),
      ),
      body: sortedNotes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      color: colors.accent,
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nie masz jeszcze notatek',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dodaj notatkę i ustaw przypomnienie, jeśli chcesz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.muted),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              children: [
                AppSectionHeading(
                  icon: Icons.notes_rounded,
                  title: 'Twoje notatki',
                  subtitle:
                      '${notes.length} ${_noteCountLabel(notes.length)} zapisanych na tym urządzeniu.',
                ),
                const SizedBox(height: 14),
                for (final note in sortedNotes) ...[
                  _NoteCard(
                    note: note,
                    onTap: () => _editNote(context, note),
                    onDelete: () => _confirmDelete(context, note),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Future<void> _editNote(BuildContext context, [PersonalNote? note]) async {
    final updatedNote = await showDialog<PersonalNote>(
      context: context,
      builder: (context) => _PersonalNoteDialog(note: note),
    );
    if (!context.mounted || updatedNote == null) return;

    await onSaveNote(
      note == null
          ? PersonalNote(
              id: _nextAvailableId(),
              title: updatedNote.title,
              content: updatedNote.content,
              reminderAt: updatedNote.reminderAt,
            )
          : updatedNote,
    );
  }

  int _nextAvailableId() {
    final usedIds = notes.map((note) => note.id).toSet();
    var candidate = 1000000;
    while (usedIds.contains(candidate)) {
      candidate++;
    }
    return candidate;
  }

  Future<void> _confirmDelete(BuildContext context, PersonalNote note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usunąć notatkę?'),
        content: Text('Notatka „${note.title}” zostanie usunięta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) await onDeleteNote(note);
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final PersonalNote note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AppSurfaceCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.note_alt_outlined, color: colors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      note.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.muted,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                    if (note.reminderAt case final reminderAt?) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: colors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatReminder(reminderAt),
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Usuń notatkę',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalNoteDialog extends StatefulWidget {
  const _PersonalNoteDialog({this.note});

  final PersonalNote? note;

  @override
  State<_PersonalNoteDialog> createState() => _PersonalNoteDialogState();
}

class _PersonalNoteDialogState extends State<_PersonalNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _reminderAt;
  late bool _reminderEnabled;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _reminderAt =
        widget.note?.reminderAt ?? DateTime.now().add(const Duration(hours: 1));
    _reminderEnabled = widget.note?.reminderAt != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return AlertDialog(
      scrollable: true,
      title: Text(isEditing ? 'Edytuj notatkę' : 'Nowa notatka'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Tytuł'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Wpisz tytuł notatki.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Treść notatki'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Wpisz treść notatki.'
                  : null,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Przypomnij o notatce'),
              value: _reminderEnabled,
              onChanged: (enabled) =>
                  setState(() => _reminderEnabled = enabled),
            ),
            if (_reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: const Text('Data i godzina'),
                subtitle: Text(_formatReminder(_reminderAt)),
                onTap: _chooseReminder,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }

  Future<void> _chooseReminder() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _reminderAt.year,
      _reminderAt.month,
      _reminderAt.day,
    );
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(today) ? today : selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 3650)),
      helpText: 'Data przypomnienia',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt),
      helpText: 'Godzina przypomnienia',
    );
    if (time == null || !mounted) return;
    setState(
      () => _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_reminderEnabled && !_reminderAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ustaw przypomnienie na późniejszą datę i godzinę.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      PersonalNote(
        id: widget.note?.id ?? 0,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        reminderAt: _reminderEnabled ? _reminderAt : null,
      ),
    );
  }
}

String _noteCountLabel(int count) {
  if (count == 1) return 'notatkę';
  if (count % 10 >= 2 &&
      count % 10 <= 4 &&
      (count % 100 < 12 || count % 100 > 14)) {
    return 'notatki';
  }
  return 'notatek';
}

String _formatReminder(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day.$month.${dateTime.year} • $hour:$minute';
}
