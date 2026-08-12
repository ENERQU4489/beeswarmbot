<# :
@echo off
title Test Antycheata - Ruch po prostokacie + Auto-Clicker
color 0A
:: Sprawdzenie i automatyczne podniesienie uprawnien do Administratora
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Uruchamianie z uprawnieniami Administratora...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Uruchomienie zaszytego skryptu PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content '%~f0' -Raw)"
pause
exit /b
#>

# ==============================================================================
# KOD POWERSHELL + C# (Ready-To-Run)
# ==============================================================================

# Kompilacja C# do niskopoziomowej obslugi klawiatury i myszy (DirectInput / Scancodes)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class GameController
{
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const uint KEYEVENTF_SCANCODE = 0x0008;

    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;

    // Virtual Key Codes
    public const byte VK_W = 0x57;
    public const byte VK_A = 0x41;
    public const byte VK_S = 0x53;
    public const byte VK_D = 0x44;
    public const byte VK_F7 = 0x76; // Start / Wznowienie [F7]
    public const byte VK_F8 = 0x77; // Pauza / Zatrzymanie [F8]

    // Hardware Scancodes dla silnikow gier 3D (Unity / Unreal Engine)
    public const byte SCAN_W = 0x11;
    public const byte SCAN_A = 0x1E;
    public const byte SCAN_S = 0x1F;
    public const byte SCAN_D = 0x20;

    public static void KeyDown(byte vk, byte scan)
    {
        keybd_event(vk, scan, KEYEVENTF_SCANCODE, UIntPtr.Zero);
    }

    public static void KeyUp(byte vk, byte scan)
    {
        keybd_event(vk, scan, KEYEVENTF_SCANCODE | KEYEVENTF_KEYUP, UIntPtr.Zero);
    }

    public static void MouseDown()
    {
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
    }

    public static void MouseUp()
    {
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }

    public static void ReleaseAll()
    {
        KeyUp(VK_W, SCAN_W);
        KeyUp(VK_A, SCAN_A);
        KeyUp(VK_S, SCAN_S);
        KeyUp(VK_D, SCAN_D);
        MouseUp();
    }

    public static bool IsF7Pressed()
    {
        return (GetAsyncKeyState(VK_F7) & 0x8000) != 0;
    }

    public static bool IsF8Pressed()
    {
        return (GetAsyncKeyState(VK_F8) & 0x8000) != 0;
    }
}
"@

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   TEST ANTYCHEATA - RUCH + AUTO-CLICKER (FPP / 3D)       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Wzorzec ruchu:  D (2s) -> W (1s) -> A (2s) -> S (1s)" -ForegroundColor Yellow
Write-Host " Myszka:         Klik trzymany 1s, puszczony 0.5s" -ForegroundColor Yellow
Write-Host "----------------------------------------------------------" -ForegroundColor Gray
Write-Host " [F7] -> START / WZNOWIENIE skryptu" -ForegroundColor Green
Write-Host " [F8] -> PAUZA / ZATRZYMANIE skryptu" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "`nOczekiwanie na wcisniecie [F7]..." -ForegroundColor Yellow

$isPaused = $true

# Definicje krokow ruchu
$steps = @(
    @{ Name = "D (2s)"; Vk = [GameController]::VK_D; Scan = [GameController]::SCAN_D; Duration = 2.0 },
    @{ Name = "W (1s)"; Vk = [GameController]::VK_W; Scan = [GameController]::SCAN_W; Duration = 1.0 },
    @{ Name = "A (2s)"; Vk = [GameController]::VK_A; Scan = [GameController]::SCAN_A; Duration = 2.0 },
    @{ Name = "S (1s)"; Vk = [GameController]::VK_S; Scan = [GameController]::SCAN_S; Duration = 1.0 }
)

$currentStepIndex = 0
$moveStepStartTime = [System.DateTime]::Now

# Stan myszki: $true = wcisnieta, $false = puszczona
$isMouseDown = $false
$mouseStateStartTime = [System.DateTime]::Now

try {
    while ($true) {
        # --- OBSLUGA GORACYCH KLAWISZY (F7 / F8) ---
        if ([GameController]::IsF7Pressed()) {
            if ($isPaused) {
                $isPaused = $false
                Clear-Host
                Write-Host "==========================================================" -ForegroundColor Cyan
                Write-Host "   [AKTYWNY] Skrypt wykonuje ruch i cykliczne klikanie!   " -ForegroundColor Green
                Write-Host "   Wcisnij [F8], aby PAUZOWAC skrypt.                      " -ForegroundColor Red
                Write-Host "==========================================================" -ForegroundColor Cyan
                
                # Inicjalizacja pierwszego kroku
                $currentStepIndex = 0
                $step = $steps[$currentStepIndex]
                [GameController]::KeyDown([byte]$step.Vk, [byte]$step.Scan)
                $moveStepStartTime = [System.DateTime]::Now
                Write-Host "--> Ruch: $($step.Name)" -ForegroundColor Gray

                # Inicjalizacja myszki (wcisniecie)
                [GameController]::MouseDown()
                $isMouseDown = $true
                $mouseStateStartTime = [System.DateTime]::Now

                Start-Sleep -Milliseconds 300 # Debounce F7
            }
        }

        if ([GameController]::IsF8Pressed()) {
            if (-not $isPaused) {
                $isPaused = $true
                [GameController]::ReleaseAll()
                Write-Host "`n[PAUZA] Zatrzymano ruch i klikanie. Wcisnij [F7], aby wznowic." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 300 # Debounce F8
            }
        }

        # --- LOGIKA WYKONANIA RUCHU I KLIKANIA (GDY AKTYWNY) ---
        if (-not $isPaused) {
            $now = [System.DateTime]::Now

            # 1. Logika cyklicznego klikania myszka (1s wcisnieta, 0.5s puszczona)
            $mouseElapsed = ($now - $mouseStateStartTime).TotalSeconds
            if ($isMouseDown -and $mouseElapsed -ge 1.0) {
                [GameController]::MouseUp()
                $isMouseDown = $false
                $mouseStateStartTime = $now
            }
            elseif (-not $isMouseDown -and $mouseElapsed -ge 0.5) {
                [GameController]::MouseDown()
                $isMouseDown = $true
                $mouseStateStartTime = $now
            }

            # 2. Logika sekwencji ruchu postaci
            $moveElapsed = ($now - $moveStepStartTime).TotalSeconds
            $currentStep = $steps[$currentStepIndex]

            if ($moveElapsed -ge $currentStep.Duration) {
                # Pusc stary klawisz
                [GameController]::KeyUp([byte]$currentStep.Vk, [byte]$currentStep.Scan)

                # Przejdz do nastepnego kroku
                $currentStepIndex = ($currentStepIndex + 1) % $steps.Count
                $nextStep = $steps[$currentStepIndex]

                # Wcisnij nowy klawisz
                [GameController]::KeyDown([byte]$nextStep.Vk, [byte]$nextStep.Scan)
                $moveStepStartTime = $now
                Write-Host "--> Ruch: $($nextStep.Name)" -ForegroundColor Gray
            }
        }

        Start-Sleep -Milliseconds 20
    }
}
finally {
    [GameController]::ReleaseAll()
    Write-Host "`n[STOP] Skrypt zakonczony, zwolniono przyciski." -ForegroundColor Green
}
