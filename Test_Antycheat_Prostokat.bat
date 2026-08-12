<# :
@echo off
title Test Antycheata - Chodzenie po prostokacie
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

# Kompilacja C# do niskopoziomowej obslugi klawiatury (Scancodes dla DirectInput)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class GameController
{
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    public const uint KEYEVENTF_KEYUP = 0x0002;
    public const uint KEYEVENTF_SCANCODE = 0x0008;

    // Virtual Key Codes
    public const byte VK_W = 0x57;
    public const byte VK_A = 0x41;
    public const byte VK_S = 0x53;
    public const byte VK_D = 0x44;
    public const byte VK_F8 = 0x77; // Klawisz zatrzymania [F8]

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

    public static bool IsF8Pressed()
    {
        return (GetAsyncKeyState(VK_F8) & 0x8000) != 0;
    }
}
"@

# Funkcja pomocnicza trzymujaca klawisz z mozliwoscia przerwania klawiszem F8
function Hold-KeyWithCancel {
    param(
        [byte]$vk,
        [byte]$scan,
        [double]$seconds
    )
    
    [GameController]::KeyDown($vk, $scan)
    $startTime = [System.DateTime]::Now
    
    while (([System.DateTime]::Now - $startTime).TotalSeconds -lt $seconds) {
        if ([GameController]::IsF8Pressed()) {
            [GameController]::KeyUp($vk, $scan)
            return $true # Flaga przerwano
        }
        Start-Sleep -Milliseconds 20
    }
    
    [GameController]::KeyUp($vk, $scan)
    return $false
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   TEST ANTYCHEATA - RUCH PO PROSTOKACIE (FPP / 3D)       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Masz 5 sekund na klikniecie w okno gry..." -ForegroundColor Yellow

for ($i = 5; $i -gt 0; $i--) {
    Write-Host "Start za: $i sek..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

Write-Host "`n[START] Ruch rozpoczety!" -ForegroundColor Green
Write-Host "Wcisnij [F8] w dowolnym momencie, aby natychmiast ZATRZYMAC skrypt." -ForegroundColor Red

$cancelled = $false

try {
    while (-not $cancelled) {
        # 1. Przod - 2 sekundy
        Write-Host "--> Przod (2s)" -ForegroundColor Gray
        $cancelled = Hold-KeyWithCancel -vk ([GameController]::VK_W) -scan ([GameController]::SCAN_W) -seconds 2.0
        if ($cancelled) { break }
        Start-Sleep -Milliseconds 100

        # 2. Prawo - 1 sekunda
        Write-Host "--> Prawo (1s)" -ForegroundColor Gray
        $cancelled = Hold-KeyWithCancel -vk ([GameController]::VK_D) -scan ([GameController]::SCAN_D) -seconds 1.0
        if ($cancelled) { break }
        Start-Sleep -Milliseconds 100

        # 3. Tyl - 2 sekundy
        Write-Host "--> Tyl (2s)" -ForegroundColor Gray
        $cancelled = Hold-KeyWithCancel -vk ([GameController]::VK_S) -scan ([GameController]::SCAN_S) -seconds 2.0
        if ($cancelled) { break }
        Start-Sleep -Milliseconds 100

        # 4. Lewo - 1 sekunda
        Write-Host "--> Lewo (1s)" -ForegroundColor Gray
        $cancelled = Hold-KeyWithCancel -vk ([GameController]::VK_A) -scan ([GameController]::SCAN_A) -seconds 1.0
        if ($cancelled) { break }
        Start-Sleep -Milliseconds 100
    }
}
finally {
    # Zabezpieczenie: zwolnienie wszystkich klawiszy przy wyjsciu
    [GameController]::KeyUp([GameController]::VK_W, [GameController]::SCAN_W)
    [GameController]::KeyUp([GameController]::VK_A, [GameController]::SCAN_A)
    [GameController]::KeyUp([GameController]::VK_S, [GameController]::SCAN_S)
    [GameController]::KeyUp([GameController]::VK_D, [GameController]::SCAN_D)
    Write-Host "`n[STOP] Zwolniono klawisze. Skrypt zakonczony z sukcesem." -ForegroundColor Green
}
