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
- Pulpit pokazuje skrót dzisiejszego treningu i tygodniowy wykres aktywności;
  Plan zawiera listę ćwiczeń, notatki i zapisane schematy bez powielonej karty.
- Schematy tworzy się w Ustawieniach, wybierając typ i ćwiczenia z lokalnej
  bazy ponad 50 ćwiczeń; wyszukiwarka filtruje po nazwie, partii, sprzęcie
  i miejscu (dom, siłownia lub plener). Długość przerw ustawia się dla każdego
  schematu.
- Własne nazwane schematy można planować na wybrane dni
  kalendarza i dodawać osobne notatki do dnia oraz zaplanowanego treningu.
- W profilu dostępny jest kalkulator BMI z orientacyjną interpretacją wyniku.
- Własne schematy, przypisane treningi i notatki dni są zapisywane lokalnie.
- Sesja prowadzi przez ćwiczenia i serie, odlicza przerwę oraz pozwala ją
  pominąć przed przejściem dalej. W czasie przerwy wyświetla odliczanie
  systemowe i przypomina po jej końcu.
- Na iOS 16.1+ Live Activity wyświetla odliczanie na ekranie blokady i Dynamic
  Island na zgodnych iPhone'ach. Android 24+ pokazuje odliczanie w bieżącym
  powiadomieniu. Starsze lub nieobsługiwane urządzenia otrzymują lokalne
  powiadomienie o końcu przerwy. System może poprosić o dostęp do powiadomień
  i dokładnych alarmów; bez dokładnych alarmów Android może opóźnić przypomnienie.
- W Ustawieniach można wybrać motyw systemowy, jasny lub ciemny oraz jedną
  z pięciu palet kolorystycznych.
- Ustawienia ogólne pozwalają wybrać domyślną przerwę. Prywatność zawiera
  rozwijane artykuły o przechowywaniu danych i pozwala ukryć nazwę oraz
  statystyki profilu; preferencje są trwale zapisywane lokalnie.
- Można ustawić cotygodniowe przypomnienia o treningu: w wybrane dni i o
  wybranej lokalnej godzinie. Harmonogram działa jako powiadomienia systemowe,
  także po ponownym uruchomieniu urządzenia; dokładny czas zależy od uprawnień
  powiadomień i alarmów systemowych. Gdy przypomnienia są wyłączone, dostępna
  jest tylko opcja ich włączenia; ustawienia dni i godziny pojawiają się po
  aktywacji.
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
