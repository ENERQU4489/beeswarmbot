<# :
@echo off
title Test Antycheata - Made by 4489
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
# KOD POWERSHELL + C# (Ready-To-Run) - MADE BY 4489
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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

# Funkcje animacji CLI
function Show-Banner {
    param([string]$statusText = "STANDBY", [ConsoleColor]$statusColor = [ConsoleColor]::Yellow)

    Clear-Host
    $banner = @"
  __  __    _    ____  _____   ______   __  _  _  _  _  ___   ___ 
 |  \/  |  / \  |  _ \|  ___| |  _ \ \ / / | || || || _ \ / _ \
 | |\/| | / _ \ | | | |  __|  | |_) \ V /  | || || ||   /| (_) |
 | |  | |/ ___ \| |_| | |___  |  _ < | |   |__   _||_"\  \__, |
 |_|  |_/_/   \_\____/|_____| |_| \_\|_|      |_|  |___|  /_/  
"@
    Write-Host $banner -ForegroundColor Cyan
    Write-Host " ==============================================================" -ForegroundColor DarkGray
    Write-Host "   ANTI-CHEAT TEST BOT | FPP & 3D BOT SIMULATOR" -ForegroundColor Gray
    Write-Host "   STATUS: " -NoNewline -ForegroundColor White
    Write-Host " [$statusText] " -ForegroundColor $statusColor
    Write-Host " ==============================================================" -ForegroundColor DarkGray
    Write-Host "  [F7] -> START / WZNOWIENIE   |   [F8] -> PAUZA / STOP" -ForegroundColor Green
    Write-Host " ==============================================================" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-IntroAnimation {
    Clear-Host
    $colors = @([ConsoleColor]::DarkCyan, [ConsoleColor]::Cyan, [ConsoleColor]::Green, [ConsoleColor]::White)
    
    foreach ($col in $colors) {
        Show-Banner -statusText "INICJALIZACJA..." -statusColor $col
        Start-Sleep -Milliseconds 120
    }
}

# Animowane symbole spinnera
$spinnerFrames = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
$spinnerIndex = 0

# Sekwencja krokow ruchu
$steps = @(
    @{ Name = "RUCH W PRAWO (D)"; Vk = [GameController]::VK_D; Scan = [GameController]::SCAN_D; Duration = 2.0 },
    @{ Name = "RUCH W PRZOD (W)"; Vk = [GameController]::VK_W; Scan = [GameController]::SCAN_W; Duration = 1.0 },
    @{ Name = "RUCH W LEWO  (A)"; Vk = [GameController]::VK_A; Scan = [GameController]::SCAN_A; Duration = 2.0 },
    @{ Name = "RUCH W TYL   (S)"; Vk = [GameController]::VK_S; Scan = [GameController]::SCAN_S; Duration = 1.0 }
)

# Start animacji intro
Show-IntroAnimation
Show-Banner -statusText "OCZEKIWANIE NA F7" -statusColor [ConsoleColor]::Yellow
Write-Host " Przejdz do okna gry i wcisnij [F7], aby rozpoczac..." -ForegroundColor Yellow

$isPaused = $true
$currentStepIndex = 0
$moveStepStartTime = [System.DateTime]::Now

$isMouseDown = $false
$mouseStateStartTime = [System.DateTime]::Now
$totalActiveTime = [System.TimeSpan]::Zero
$lastActiveStart = [System.DateTime]::Now

try {
    while ($true) {
        # --- OBSLUGA GORACYCH KLAWISZY (F7 / F8) ---
        if ([GameController]::IsF7Pressed()) {
            if ($isPaused) {
                $isPaused = $false
                $lastActiveStart = [System.DateTime]::Now
                
                # Inicjalizacja pierwszego kroku
                $currentStepIndex = 0
                $step = $steps[$currentStepIndex]
                [GameController]::KeyDown([byte]$step.Vk, [byte]$step.Scan)
                $moveStepStartTime = [System.DateTime]::Now

                # Inicjalizacja myszki (wcisniecie)
                [GameController]::MouseDown()
                $isMouseDown = $true
                $mouseStateStartTime = [System.DateTime]::Now

                Show-Banner -statusText "BOT AKTYWNY (DZIALA)" -statusColor [ConsoleColor]::Green
                Start-Sleep -Milliseconds 300 # Debounce
            }
        }

        if ([GameController]::IsF8Pressed()) {
            if (-not $isPaused) {
                $isPaused = $true
                [GameController]::ReleaseAll()
                $totalActiveTime += ([System.DateTime]::Now - $lastActiveStart)

                Show-Banner -statusText "PAUZA (WSTRZYMANY)" -statusColor [ConsoleColor]::Red
                Write-Host " [PAUZA] Wcisnij [F7], aby wznowic ruch..." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 300 # Debounce
            }
        }

        # --- WYKONANIE I DYNAMICZNA ANIMACJA DASHBOARDU ---
        if (-not $isPaused) {
            $now = [System.DateTime]::Now

            # 1. Logika klikania myszka (1s wcisnieta / 0.5s puszczona)
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

            # 2. Logika sekwencji ruchu
            $moveElapsed = ($now - $moveStepStartTime).TotalSeconds
            $currentStep = $steps[$currentStepIndex]

            if ($moveElapsed -ge $currentStep.Duration) {
                [GameController]::KeyUp([byte]$currentStep.Vk, [byte]$currentStep.Scan)

                $currentStepIndex = ($currentStepIndex + 1) % $steps.Count
                $nextStep = $steps[$currentStepIndex]

                [GameController]::KeyDown([byte]$nextStep.Vk, [byte]$nextStep.Scan)
                $moveStepStartTime = $now
                $currentStep = $nextStep
                $moveElapsed = 0.0
            }

            # 3. Odswiezanie animowanego interfejsu CLI
            $spinner = $spinnerFrames[$spinnerIndex]
            $spinnerIndex = ($spinnerIndex + 1) % $spinnerFrames.Count

            $lpmStatus = if ($isMouseDown) { "LPM: [WCIŚNIĘTY ]" } else { "LPM: [PUSZCZONY ]" }
            $lpmColor = if ($isMouseDown) { [ConsoleColor]::Green } else { [ConsoleColor]::DarkGray }

            $timeStr = ($totalActiveTime + ($now - $lastActiveStart)).ToString("mm\:ss")

            # Nadpisywanie linii w konsoli (efekt zywej animacji)
            [Console]::SetCursorPosition(0, 10)
            Write-Host "  $spinner " -NoNewline -ForegroundColor Cyan
            Write-Host "AKTUALNY RUCH: " -NoNewline -ForegroundColor White
            Write-Host ("{0,-20}" -f $currentStep.Name) -NoNewline -ForegroundColor Yellow
            Write-Host " | " -NoNewline -ForegroundColor DarkGray
            Write-Host $lpmStatus -NoNewline -ForegroundColor $lpmColor
            Write-Host " | " -NoNewline -ForegroundColor DarkGray
            Write-Host "CZAS: $timeStr  " -ForegroundColor Memory

            Start-Sleep -Milliseconds 80
        }
        else {
            Start-Sleep -Milliseconds 50
        }
    }
}
finally {
    [GameController]::ReleaseAll()
    Write-Host "`n [STOP] Zwolniono klawisze. Do widzenia!" -ForegroundColor Red
}
