import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_settings.dart';
import 'rest_duration_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.settings,
    required this.settingsError,
    required this.onThemeChanged,
    required this.onRestChanged,
    required this.onProfileNameChanged,
    required this.onProfileStatsChanged,
    super.key,
  });

  final AppSettings settings;
  final String? settingsError;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<bool> onProfileNameChanged;
  final ValueChanged<bool> onProfileStatsChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          if (widget.settingsError != null) ...[
            _SettingsErrorBanner(
              message: widget.settingsError!,
              colors: colors,
            ),
            const SizedBox(height: 12),
          ],
          const _SettingsSectionTitle(
            icon: Icons.tune_rounded,
            title: 'Ogólne',
            subtitle: 'Dopasuj wygląd i przebieg treningów.',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: colors.accent),
                  title: const Text('Motyw aplikacji'),
                  subtitle: Text(_themeName(_settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _chooseTheme(context),
                ),
                Divider(height: 1, color: colors.muted.withValues(alpha: 0.16)),
                RestDurationPicker(
                  title: 'Domyślna przerwa',
                  seconds: _settings.defaultRestSeconds,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        defaultRestSeconds: value,
                      ),
                    );
                    widget.onRestChanged(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const _SettingsSectionTitle(
            icon: Icons.shield_outlined,
            title: 'Prywatność',
            subtitle: 'Wybierz, jakie informacje widzisz w swoim profilu.',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.person_outline_rounded,
                    color: colors.accent,
                  ),
                  title: const Text('Pokaż nazwę profilu'),
                  subtitle: const Text(
                    'Gdy wyłączysz, nazwa zostanie ukryta na ekranie profilu.',
                  ),
                  value: _settings.showProfileName,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        showProfileName: value,
                      ),
                    );
                    widget.onProfileNameChanged(value);
                  },
                ),
                Divider(height: 1, color: colors.muted.withValues(alpha: 0.16)),
                SwitchListTile(
                  secondary: Icon(
                    Icons.insights_outlined,
                    color: colors.accent,
                  ),
                  title: const Text('Pokaż statystyki profilu'),
                  subtitle: const Text(
                    'Ukrywa liczbę treningów, czas i punkty na profilu.',
                  ),
                  value: _settings.showProfileStats,
                  onChanged: (value) {
                    setState(
                      () => _settings = _settings.copyWith(
                        showProfileStats: value,
                      ),
                    );
                    widget.onProfileStatsChanged(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PrivacyInfoCard(colors: colors),
          const SizedBox(height: 25),
          const _SettingsSectionTitle(
            icon: Icons.info_outline_rounded,
            title: 'Informacje',
            subtitle: 'Przejrzyste zasady działania aplikacji.',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            child: ListTile(
              leading: Icon(Icons.storage_outlined, color: colors.accent),
              title: const Text('Dane i przechowywanie'),
              subtitle: const Text(
                'Ustawienia są zapisywane lokalnie na tym urządzeniu.',
              ),
              onTap: () => _showStorageInfo(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseTheme(BuildContext context) async {
    final colors = GymColors.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  'Motyw aplikacji',
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              RadioGroup<ThemeMode>(
                groupValue: _settings.themeMode,
                onChanged: (mode) {
                  if (mode == null) return;
                  setState(
                    () => _settings = _settings.copyWith(themeMode: mode),
                  );
                  widget.onThemeChanged(mode);
                  Navigator.pop(sheetContext);
                },
                child: Column(
                  children: [
                    for (final option in [
                      (
                        ThemeMode.system,
                        'Systemowy',
                        Icons.settings_brightness_rounded,
                      ),
                      (ThemeMode.light, 'Jasny', Icons.light_mode_rounded),
                      (ThemeMode.dark, 'Ciemny', Icons.dark_mode_rounded),
                    ])
                      RadioListTile<ThemeMode>(
                        value: option.$1,
                        title: Text(option.$2),
                        secondary: Icon(option.$3, color: colors.accent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Twoje dane'),
        content: const Text(
          'Aplikacja nie wysyła ustawień profilu do żadnego serwera. '
          'Preferencje są przechowywane lokalnie na urządzeniu. '
          'Treningi i notatki pozostają w pamięci bieżącej sesji.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Zgodny z ustawieniami systemu',
    ThemeMode.light => 'Jasny',
    ThemeMode.dark => 'Ciemny',
  };
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.accent),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GymColors.of(context).surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _PrivacyInfoCard extends StatelessWidget {
  const _PrivacyInfoCard({required this.colors});

  final GymColors colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colors.accent.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: colors.accent, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Profil jest prywatny i widoczny tylko w tej aplikacji. '
            'Nie ma tu konta online ani udostępniania danych innym osobom.',
            style: TextStyle(
              color: colors.foreground,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SettingsErrorBanner extends StatelessWidget {
  const _SettingsErrorBanner({required this.message, required this.colors});

  final String message;
  final GymColors colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: colors.foreground, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}
