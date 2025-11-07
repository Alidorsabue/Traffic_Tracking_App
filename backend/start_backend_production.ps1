# Script PowerShell pour demarrer le backend Flask en mode PRODUCTION
# Usage: .\start_backend_production.ps1
#
# IMPORTANT: Ce script utilise Waitress (serveur WSGI) au lieu du serveur de developpement Flask
# Ne pas utiliser pour le developpement - utilisez start_backend.ps1 a la place

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Backend Flask - MODE PRODUCTION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que le venv existe
if (-not (Test-Path ".venv")) {
    Write-Host "[ERREUR] Environnement virtuel non trouve. Executez d'abord: py -3 -m venv .venv" -ForegroundColor Red
    exit 1
}

# Verifier que Waitress est installe
$pythonPath = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $pythonPath)) {
    Write-Host "[ERREUR] Python dans venv non trouve: $pythonPath" -ForegroundColor Red
    exit 1
}

# Verifier que Waitress est installe
Write-Host "[INFO] Verification de Waitress..." -ForegroundColor Cyan
try {
    $null = & $pythonPath -c "import waitress" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Waitress est installe" -ForegroundColor Green
    } else {
        throw "Waitress non trouve"
    }
} catch {
    Write-Host "[WARNING] Waitress n'est pas installe" -ForegroundColor Yellow
    Write-Host "[INFO] Installation de Waitress..." -ForegroundColor Cyan
    & $pythonPath -m pip install waitress --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERREUR] Impossible d'installer Waitress" -ForegroundColor Red
        Write-Host "[INFO] Essayez d'installer manuellement: pip install waitress" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "[OK] Waitress installe avec succes" -ForegroundColor Green
}
Write-Host ""

# Charger les variables d'environnement depuis .env.production si existe, sinon .env
$envFile = ".env.production"
if (-not (Test-Path $envFile)) {
    $envFile = ".env"
    Write-Host "[WARNING] Fichier .env.production non trouve, utilisation de .env" -ForegroundColor Yellow
    Write-Host "[INFO] Pour la production, creez un fichier .env.production avec FLASK_DEBUG=false" -ForegroundColor Cyan
}

if (-not (Test-Path $envFile)) {
    Write-Host "[WARNING] Fichier $envFile non trouve. Verifiez votre configuration." -ForegroundColor Yellow
}

# Charger les variables d'environnement
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($name -and $value) {
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}

# Configuration Waitress
$waitressHost = [Environment]::GetEnvironmentVariable("WAITRESS_HOST", "Process")
if (-not $waitressHost) { $waitressHost = "0.0.0.0" }

$port = [Environment]::GetEnvironmentVariable("WAITRESS_PORT", "Process")
if (-not $port) { $port = [Environment]::GetEnvironmentVariable("FLASK_PORT", "Process") }
if (-not $port) { $port = "5000" }

$threads = [Environment]::GetEnvironmentVariable("WAITRESS_THREADS", "Process")
if (-not $threads) { $threads = "4" }

$channelTimeout = [Environment]::GetEnvironmentVariable("WAITRESS_CHANNEL_TIMEOUT", "Process")
if (-not $channelTimeout) { $channelTimeout = "120" }

$debug = [Environment]::GetEnvironmentVariable("FLASK_DEBUG", "Process")
# Forcer FLASK_DEBUG=false en production
[Environment]::SetEnvironmentVariable("FLASK_DEBUG", "false", "Process")
if ($debug -eq "true") {
    Write-Host "[WARNING] FLASK_DEBUG=true detecte dans $envFile - force a false pour la production" -ForegroundColor Yellow
}

Write-Host "[OK] Python trouve: $pythonPath" -ForegroundColor Green
Write-Host "[INFO] Configuration:" -ForegroundColor Cyan
Write-Host "  Serveur: Waitress (WSGI)" -ForegroundColor Yellow
Write-Host "  Host: $waitressHost" -ForegroundColor Yellow
Write-Host "  Port: $port" -ForegroundColor Yellow
Write-Host "  Threads: $threads" -ForegroundColor Yellow
Write-Host "  Timeout: $channelTimeout secondes" -ForegroundColor Yellow
Write-Host "  Fichier env: $envFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "[INFO] Demarrage du serveur en mode PRODUCTION..." -ForegroundColor Green
Write-Host "[INFO] Le serveur ecoute sur $waitressHost`:$port" -ForegroundColor Cyan
Write-Host "[INFO] Acces depuis votre navigateur: http://localhost:$port" -ForegroundColor Green
Write-Host ""

# Creer le dossier logs s'il n'existe pas
$logsDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Verifier que wsgi.py existe
$wsgiPath = Join-Path $PSScriptRoot "wsgi.py"
if (-not (Test-Path $wsgiPath)) {
    Write-Host "[ERREUR] Fichier wsgi.py non trouve: $wsgiPath" -ForegroundColor Red
    Write-Host "[INFO] Le fichier wsgi.py est necessaire pour la production" -ForegroundColor Yellow
    exit 1
}

# Lancer Waitress
Write-Host "[INFO] Demarrage de Waitress..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Appuyez sur Ctrl+C pour arreter le serveur" -ForegroundColor Yellow
Write-Host ""

# Changer le répertoire de travail vers le dossier backend
Push-Location $PSScriptRoot

try {
    # Utiliser waitress-serve (commande directe de Waitress)
    # Le --call wsgi:application permet d'appeler directement l'objet application
    $waitressCmd = Join-Path $PSScriptRoot ".venv\Scripts\waitress-serve.exe"
    if (Test-Path $waitressCmd) {
        & $waitressCmd `
            --host=$waitressHost `
            --port=$port `
            --threads=$threads `
            --channel-timeout=$channelTimeout `
            wsgi:application
    } else {
        # Fallback: utiliser python -m waitress
        & $pythonPath -m waitress `
            --host=$waitressHost `
            --port=$port `
            --threads=$threads `
            --channel-timeout=$channelTimeout `
            wsgi:application
    }
} catch {
    Write-Host ""
    Write-Host "[ERREUR] Erreur lors du demarrage de Waitress" -ForegroundColor Red
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "[INFO] Verifiez que:" -ForegroundColor Yellow
    Write-Host "  1. Waitress est installe: pip install waitress" -ForegroundColor Cyan
    Write-Host "  2. Le fichier wsgi.py existe" -ForegroundColor Cyan
    Write-Host "  3. app.py est accessible" -ForegroundColor Cyan
    Write-Host "  4. Les dependances sont installees: pip install -r requirements.txt" -ForegroundColor Cyan
    Pop-Location
    exit 1
} finally {
    # Restaurer le répertoire de travail
    Pop-Location
}

