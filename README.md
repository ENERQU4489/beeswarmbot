# Test Antycheata / AFK Bot - Ruch + Auto-Clicker

Skrypt służący do automatycznego testowania wykrywania botów, auto-clickera oraz sztucznego ruchu postaci w grach 3D.

## Opis działania

Skrypt emuluje ruch postaci po obwodzie prostokąta przy jednoczesnym cyklicznym klikaniu lewym przyciskiem myszy. Używa sprzętowych kodów skanowania **DirectInput (Hardware Scancodes)**.

### Sterowanie:
* **[F7]**: Start / Wznowienie działania skryptu
* **[F8]**: Pauza / Zatrzymanie ruchu i klikania (zwolnienie klawiszy)

### Wzorzec ruchu (w pętli):
1. **`D`**: 2 sekundy
2. **`W`**: 1 sekunda
3. **`A`**: 2 sekundy
4. **`S`**: 1 sekunda

### Cykl klikania myszką:
* **1 sekunda**: Lewy przycisk myszy wciśnięty (trzymany)
* **0.5 sekundy**: Lewy przycisk myszy puszczony
* Pętla powtarza się równolegle z ruchem postaci.

## Jak uruchomić?

1. Pobierz plik `Test_Antycheat_Prostokat.bat`.
2. Uruchom go dwukrotnym kliknięciem (skrypt automatycznie poprosi o uprawnienia Administratora).
3. Przejdź do okna gry i naciśnij **[F7]**, aby rozpocząć.
4. Naciśnij **[F8]**, aby wstrzymać działanie skryptu.
