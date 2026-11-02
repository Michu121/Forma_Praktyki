# Forma

Mobilna aplikacja treningowa z planem ćwiczeń, kalendarzem, profilem oraz
systemem punktów i rang.

## Funkcje

- Aktualna data i miesiąc są wyznaczane z zegara urządzenia.
- Kalendarz pozwala zmieniać miesiące i wybierać dni. Kolory oznaczają treningi
  wykonane, zaplanowane i bieżący dzień.
- Zakończenie treningu dodaje 100 punktów. Punkty zwiększają rangę:
  Nowicjusz (0), Regularny (300), Atleta (800), Mistrz (1600).
- Wykresy aktywności, liczba treningów, godziny i seria aktualizują się na
  podstawie treningów zaliczonych w bieżącej sesji aplikacji.
- Na pulpicie i w planie można tworzyć schematy z wybranym typem i ćwiczeniami
  z przeszukiwanej bazy; długość przerw ustawia się dla każdego schematu.
- Własne nazwane schematy można planować na wybrane dni
  kalendarza i dodawać osobne notatki do dnia oraz zaplanowanego treningu.
- W profilu dostępny jest kalkulator BMI z orientacyjną interpretacją wyniku.
- Własne schematy, przypisane treningi i notatki dni są zapisywane lokalnie.
- Sesja prowadzi przez ćwiczenia i serie, odlicza przerwę oraz pozwala ją
  pominąć przed przejściem dalej.
- Profil udostępnia motyw jasny, ciemny lub systemowy oraz edytor notatek.
- Ustawienia ogólne pozwalają wybrać domyślną przerwę. Prywatność pozwala
  ukryć nazwę i statystyki profilu; preferencje są trwale zapisywane lokalnie.
- Czas przerwy można ustawić przewijanym selektorem minut i sekund (maksymalnie
  59:59).
- Ćwiczenia otwierają instrukcje, licznik serii i interaktywny podgląd.

Historia ukończonych treningów i zdobyte punkty są przechowywane w pamięci
bieżącej sesji. Schematy, zaplanowane treningi i notatki kalendarza są
zapisywane lokalnie na urządzeniu.

## Uruchomienie

```shell
flutter pub get
flutter run
```

Testy:

```shell
flutter test
```
