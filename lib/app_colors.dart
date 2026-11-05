import 'package:flutter/material.dart';

const appBackground = Color(0xFF101311);
const appSurface = Color(0xFF1A1F1B);
const appSurfaceLight = Color(0xFF242B25);
const appLime = Color(0xFFC5F36B);
const appMuted = Color(0xFF929A91);
const appCardRadius = 16.0;
const appCompactRadius = 12.0;

enum GymPalette {
  lime('Limonkowy', Color(0xFFC5F36B), Color(0xFF78943E)),
  ocean('Niebieski', Color(0xFF72B7FF), Color(0xFF246DAF)),
  coral('Koralowy', Color(0xFFFF9B78), Color(0xFFBD5236)),
  violet('Fioletowy', Color(0xFFC0A2FF), Color(0xFF7653BA)),
  amber('Bursztynowy', Color(0xFFF4C66D), Color(0xFF987018));

  const GymPalette(this.label, this.darkAccent, this.lightAccent);

  final String label;
  final Color darkAccent;
  final Color lightAccent;

  Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkAccent : lightAccent;
}

@immutable
class GymColors extends ThemeExtension<GymColors> {
  const GymColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.accent,
    required this.muted,
    required this.foreground,
  });

  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color accent;
  final Color muted;
  final Color foreground;

  static const dark = GymColors(
    background: appBackground,
    surface: appSurface,
    surfaceLight: appSurfaceLight,
    accent: appLime,
    muted: appMuted,
    foreground: Colors.white,
  );

  static const light = GymColors(
    background: Color(0xFFF4F6F1),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFE7EBE2),
    accent: Color(0xFF78943E),
    muted: Color(0xFF66705F),
    foreground: Color(0xFF1B2118),
  );

  static GymColors forPalette(GymPalette palette, Brightness brightness) {
    final base = brightness == Brightness.dark ? dark : light;
    return base.copyWith(accent: palette.accentFor(brightness));
  }

  static GymColors of(BuildContext context) =>
      Theme.of(context).extension<GymColors>() ?? dark;

  @override
  GymColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? accent,
    Color? muted,
    Color? foreground,
  }) => GymColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceLight: surfaceLight ?? this.surfaceLight,
    accent: accent ?? this.accent,
    muted: muted ?? this.muted,
    foreground: foreground ?? this.foreground,
  );

  @override
  GymColors lerp(ThemeExtension<GymColors>? other, double t) {
    if (other is! GymColors) return this;
    return GymColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
    );
  }
}
