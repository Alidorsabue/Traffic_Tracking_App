# Script PowerShell pour demarrer le backend Flask
# Usage: .\start_backend.ps1

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Demarrage du backend Traffic Tracking..." -ForegroundColor Green

# Verifier que le venv existe
if (-not (Test-Path ".venv")) {
    Write-Host "[ERREUR] Environnement virtuel non trouve. Executez d'abord: py -3 -m venv .venv" -ForegroundColor Red
    exit 1
}

# Verifier que le fichier .env existe
if (-not (Test-Path ".env")) {
    Write-Host "[WARNING] Fichier .env non trouve. Verifiez votre configuration." -ForegroundColor Yellow
}

# Activer le venv et lancer Flask
$pythonPath = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"

if (-not (Test-Path $pythonPath)) {
    Write-Host "[ERREUR] Python dans venv non trouve: $pythonPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Python trouve: $pythonPath" -ForegroundColor Green
Write-Host "[INFO] Demarrage du serveur Flask sur http://0.0.0.0:5000" -ForegroundColor Cyan

& $pythonPath app.py

