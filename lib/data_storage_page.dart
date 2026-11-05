import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'common_widgets.dart';

class DataStoragePage extends StatelessWidget {
  const DataStoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dane i przechowywanie'),
        backgroundColor: colors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const AppSectionHeading(
            icon: Icons.storage_outlined,
            title: 'Twoje dane',
            subtitle: 'Informacje o danych i ich przechowywaniu.',
          ),
          const SizedBox(height: 14),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Orientacyjny cel nawodnienia',
              icon: Icons.water_drop_outlined,
              content:
                  'Szacunek w aplikacji korzysta z wartości EFSA (2010): '
                  '1,6 l/dzień dla wieku 4–8 lat; 1,9 l dla dziewcząt i 2,1 l '
                  'dla chłopców w wieku 9–13 lat; od 14. roku życia 2,0 l dla '
                  'kobiet i 2,5 l dla mężczyzn. NASEM/IOM (2005) podaje inne '
                  'wartości referencyjne dla dorosłych: 2,7 l dla kobiet i '
                  '3,7 l dla mężczyzn. Są to wartości całkowitej wody '
                  '(napoje i żywność), a nie indywidualna porada medyczna. '
                  'Zapotrzebowanie zmienia się m.in. przez aktywność, upał, '
                  'ciążę i stan zdrowia. Wzrost i masa są przechowywane w '
                  'profilu, lecz nie ma jednej uznanej formuły EFSA/NASEM '
                  'przeliczającej cel na te dane. Źródła: EFSA Journal '
                  '2010;8(3):1459 (doi:10.2903/j.efsa.2010.1459) oraz '
                  'NASEM/IOM, Dietary Reference Intakes for Water (2005, '
                  'doi:10.17226/10925).',
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Jakie dane są używane?',
              icon: Icons.dataset_outlined,
              content:
                  'Aplikacja korzysta z ustawień, schematów treningowych, '
                  'zaplanowanych treningów oraz notatek, które zapisujesz. '
                  'Nie wymaga rejestracji konta.',
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Gdzie są przechowywane?',
              icon: Icons.phone_android_rounded,
              content:
                  'Ustawienia, dane profilu, zdjęcie, schematy treningowe, '
                  'kalendarz, notatki i dzienny zapis napojów są przechowywane '
                  'lokalnie na tym urządzeniu. Aplikacja nie synchronizuje '
                  'ich z kontem internetowym. Historia ukończonych treningów '
                  'jest obecnie dostępna tylko w bieżącej sesji aplikacji.',
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Co zmieniają ustawienia profilu?',
              icon: Icons.visibility_outlined,
              content:
                  'Wyłączenie nazwy lub statystyk ukrywa je w widoku profilu '
                  '(nazwa również w powitaniu). Nie usuwa zapisanych '
                  'schematów, notatek ani ustawień.',
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Powiadomienia i uprawnienia',
              icon: Icons.notifications_none_rounded,
              content:
                  'Przypomnienia o treningu, notatkach i wodzie są planowane '
                  'na urządzeniu. System może poprosić o zgodę na '
                  'powiadomienia i alarmy. Uprawnieniami możesz zarządzać '
                  'również w ustawieniach systemowych telefonu.',
            ),
          ),
          const SizedBox(height: 8),
          AppSurfaceCard(
            child: _DataArticle(
              title: 'Jak usunąć dane?',
              icon: Icons.delete_outline_rounded,
              content:
                  'Aplikacja nie ma jeszcze przycisku usuwania wszystkich '
                  'danych. Lokalne dane aplikacji możesz usunąć w ustawieniach '
                  'systemowych telefonu, czyszcząc jej pamięć lub '
                  'odinstalowując aplikację.',
            ),
          ),
        ],
      ),
    );
  }
}

class _DataArticle extends StatelessWidget {
  const _DataArticle({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colors = GymColors.of(context);
    return ExpansionTile(
      leading: Icon(icon, color: colors.accent),
      title: Text(
        title,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: TextStyle(color: colors.muted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
