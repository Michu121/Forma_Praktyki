import 'package:flutter/material.dart';

import 'app_colors.dart';

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
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      padding: EdgeInsets.fromLTRB(
        21,
        12,
        21,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: appSurface,
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
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: appLime.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ĆWICZENIE',
                    style: TextStyle(
                      color: appLime,
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
                    _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isSaved ? appLime : appMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              widget.exerciseName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Klatka piersiowa  •  4 serie  •  8–10 powtórzeń',
              style: TextStyle(color: appMuted, fontSize: 12),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34402D), Color(0xFF202720)],
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
                          color: appLime,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _showingPreview
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 35,
                          color: appBackground,
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        child: Text(
                          _showingPreview ? 'Podgląd włączony' : 'Podgląd techniki',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 19),
            const Text(
              'Jak wykonać?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 11),
            const _Instruction(
              number: '01',
              text: 'Połóż się na ławce i ustaw stopy stabilnie na podłodze.',
            ),
            const _Instruction(
              number: '02',
              text: 'Chwyć sztangę nieco szerzej niż na szerokość barków.',
            ),
            const _Instruction(
              number: '03',
              text: 'Opuszczaj ciężar spokojnie do klatki, następnie wypchnij w górę.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF24271F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: appLime, size: 19),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Wskazówka: utrzymuj łopatki ściągnięte i nie blokuj łokci.',
                      style: TextStyle(
                        color: Color(0xFFCDD1C8),
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
                    'Serie: $_completedSets / 4',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (_completedSets < 4) {
                      setState(() => _completedSets++);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(
                    _completedSets == 4 ? Icons.check_rounded : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(_completedSets == 4 ? 'Gotowe' : 'Zapisz serię'),
                  style: FilledButton.styleFrom(
                    backgroundColor: appLime,
                    foregroundColor: appBackground,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: appLime,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFBEC4BA),
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
