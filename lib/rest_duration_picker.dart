import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class RestDurationPicker extends StatelessWidget {
  const RestDurationPicker({
    required this.seconds,
    required this.onChanged,
    required this.title,
    super.key,
  });

  final int seconds;
  final ValueChanged<int> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return ListTile(
      leading: Icon(Icons.timer_outlined, color: colors.accent),
      title: Text(title),
      subtitle: const Text('Przesuń pokrętło, aby ustawić czas.'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(seconds),
            style: TextStyle(
              color: colors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: () async {
        final value = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          backgroundColor: colors.surface,
          showDragHandle: true,
          builder: (_) => _RestDurationSheet(initialSeconds: seconds),
        );
        if (value != null) onChanged(value);
      },
    );
  }
}

class _RestDurationSheet extends StatefulWidget {
  const _RestDurationSheet({required this.initialSeconds});

  final int initialSeconds;

  @override
  State<_RestDurationSheet> createState() => _RestDurationSheetState();
}

class _RestDurationSheetState extends State<_RestDurationSheet> {
  late final ValueNotifier<Duration> _duration;

  @override
  void initState() {
    super.initState();
    _duration = ValueNotifier<Duration>(
      Duration(seconds: widget.initialSeconds),
    );
  }

  @override
  void dispose() {
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ustaw czas przerwy',
              style: TextStyle(
                color: colors.foreground,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Przesuń minuty i sekundy, aby wybrać czas.',
              style: TextStyle(color: colors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<Duration>(
              valueListenable: _duration,
              builder: (context, duration, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  _formatDuration(duration.inSeconds),
                  key: ValueKey(duration.inSeconds),
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 230,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms,
                initialTimerDuration: _duration.value,
                minuteInterval: 1,
                secondInterval: 1,
                onTimerDurationChanged: (value) => _duration.value = value,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.pop(context, _duration.value.inSeconds),
                child: const Text('Zapisz czas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}
