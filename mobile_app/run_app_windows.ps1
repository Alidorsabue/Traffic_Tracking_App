# Script PowerShell pour lancer l'application Flutter sur Windows Desktop
# Usage: .\run_app_windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Demarrage de l'application Flutter sur Windows..." -ForegroundColor Green

# Chemin Flutter
$flutterPath = "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"

# Verifier que Flutter existe
if (-not (Test-Path $flutterPath)) {
    Write-Host "[ERREUR] Flutter non trouve: $flutterPath" -ForegroundColor Red
    exit 1
}

# Naviguer dans le dossier mobile_app
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "[INFO] Installation des dependances..." -ForegroundColor Cyan
& $flutterPath pub get

Write-Host "[INFO] Lancement de l'application sur Windows Desktop..." -ForegroundColor Cyan

# Lancer sur Windows
& $flutterPath run -d windows

