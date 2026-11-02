import 'package:flutter/material.dart';

import 'app_colors.dart';

Future<String?> showNoteEditor(
  BuildContext context, {
  required String initialText,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => NoteEditorSheet(initialText: initialText),
);

class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({required this.initialText, super.key});

  final String initialText;

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 21),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.edit_note_rounded, color: colors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notatka treningowa',
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zamknij edytor',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: colors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Zapisz wskazówki, ciężary lub cele na kolejny trening.',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.initialText.isEmpty,
                  minLines: 7,
                  maxLines: 12,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Zacznij pisać swoją notatkę…',
                    filled: true,
                    fillColor: colors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: colors.muted.withValues(alpha: 0.12),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: colors.accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Anuluj'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, _controller.text.trim()),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Zapisz notatkę'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.foreground,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
