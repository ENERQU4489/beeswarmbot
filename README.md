# Test Antycheata / AFK Bot - Ruch po prostokącie

Skrypt służący do automatycznego testowania wykrywania prostych botów / sztucznego ruchu postaci w grach 3D (kamera FPP/TPP).

## Opis działania

Skrypt emuluje ruch postaci po obwodzie prostokąta, używając sprzętowych kodów skanowania **DirectInput (Hardware Scancodes)**, dzięki czemu działa w silnikach takich jak Unity czy Unreal Engine.

### Wzorzec ruchu w pętli:
1. **`D`**: 2 sekundy
2. **`W`**: 1 sekunda
3. **`A`**: 2 sekundy
4. **`S`**: 1 sekunda

## Jak uruchomić?

1. Pobierz plik `Test_Antycheat_Prostokat.bat`.
2. Uruchom go dwukrotnym kliknięciem (skrypt automatycznie poprosi o uprawnienia Administratora, jeśli są wymagane).
3. Masz **5 sekund** na przejście do okna gry.
4. Aby zatrzymać skrypt w dowolnym momencie, naciśnij klawisz **[F8]**.
