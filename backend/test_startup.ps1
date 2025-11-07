# Script pour tester le démarrage du serveur et voir les erreurs en temps réel
# Usage: .\test_startup.ps1

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "TEST DE DEMARRAGE DU SERVEUR" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que nous sommes dans le bon répertoire
$backendPath = $PSScriptRoot
Write-Host "[INFO] Repertoire de travail: $backendPath" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier que le fichier batch existe
$batchFile = Join-Path $backendPath "start_backend_background.bat"
Write-Host "[1/7] Verification du fichier batch..." -ForegroundColor Yellow
if (Test-Path $batchFile) {
    Write-Host "  [OK] Fichier trouve: $batchFile" -ForegroundColor Green
} else {
    Write-Host "  [ERREUR] Fichier non trouve: $batchFile" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 2. Vérifier que l'environnement virtuel existe
Write-Host "[2/7] Verification de l'environnement virtuel..." -ForegroundColor Yellow
$venvPython = Join-Path $backendPath ".venv\Scripts\python.exe"
if (Test-Path $venvPython) {
    Write-Host "  [OK] Python trouve: $venvPython" -ForegroundColor Green
} else {
    Write-Host "  [ERREUR] Python non trouve: $venvPython" -ForegroundColor Red
    Write-Host "  [INFO] Creez l'environnement virtuel avec: py -3 -m venv .venv" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# 3. Vérifier que Waitress est installé
Write-Host "[3/7] Verification de Waitress..." -ForegroundColor Yellow
try {
    $null = & $venvPython -c "import waitress" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Waitress est installe" -ForegroundColor Green
    } else {
        throw "Waitress non trouve"
    }
} catch {
    Write-Host "  [WARNING] Waitress n'est pas installe" -ForegroundColor Yellow
    Write-Host "  [INFO] Installation de Waitress..." -ForegroundColor Cyan
    & $venvPython -m pip install waitress --quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERREUR] Impossible d'installer Waitress" -ForegroundColor Red
        exit 1
    }
    Write-Host "  [OK] Waitress installe" -ForegroundColor Green
}
Write-Host ""

# 4. Vérifier que wsgi.py existe
Write-Host "[4/7] Verification de wsgi.py..." -ForegroundColor Yellow
$wsgiFile = Join-Path $backendPath "wsgi.py"
if (Test-Path $wsgiFile) {
    Write-Host "  [OK] Fichier wsgi.py trouve" -ForegroundColor Green
} else {
    Write-Host "  [ERREUR] Fichier wsgi.py non trouve: $wsgiFile" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 5. Vérifier que le fichier .env existe
Write-Host "[5/7] Verification du fichier .env..." -ForegroundColor Yellow
$envFile = Join-Path $backendPath ".env"
$envProdFile = Join-Path $backendPath ".env.production"
if (Test-Path $envProdFile) {
    Write-Host "  [OK] Fichier .env.production trouve" -ForegroundColor Green
} elseif (Test-Path $envFile) {
    Write-Host "  [OK] Fichier .env trouve" -ForegroundColor Green
} else {
    Write-Host "  [WARNING] Aucun fichier .env trouve" -ForegroundColor Yellow
    Write-Host "  [INFO] Le serveur peut fonctionner avec les valeurs par defaut" -ForegroundColor Cyan
}
Write-Host ""

# 6. Vérifier que PostgreSQL est accessible
Write-Host "[6/7] Verification de PostgreSQL..." -ForegroundColor Yellow
try {
    # Charger les variables d'environnement
    if (Test-Path $envProdFile) {
        Get-Content $envProdFile | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                if ($name -and $value) {
                    [Environment]::SetEnvironmentVariable($name, $value, "Process")
                }
            }
        }
    } elseif (Test-Path $envFile) {
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
    
    $dbHost = [Environment]::GetEnvironmentVariable("DB_HOST", "Process")
    if (-not $dbHost) { $dbHost = "localhost" }
    $dbPort = [Environment]::GetEnvironmentVariable("DB_PORT", "Process")
    if (-not $dbPort) { $dbPort = "5433" }
    
    Write-Host "  [INFO] Tentative de connexion a PostgreSQL ($dbHost:$dbPort)..." -ForegroundColor Cyan
    $testConn = & $venvPython -c "import psycopg; conn = psycopg.connect(host='$dbHost', port=$dbPort, dbname='postgres', user='postgres', password='postgres'); print('OK'); conn.close()" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] PostgreSQL est accessible" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] PostgreSQL peut ne pas etre accessible" -ForegroundColor Yellow
        Write-Host "  [INFO] Erreur: $testConn" -ForegroundColor Gray
    }
} catch {
    Write-Host "  [WARNING] Impossible de verifier PostgreSQL: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# 7. Tester le démarrage du serveur (en mode visible pour voir les erreurs)
Write-Host "[7/7] Test de demarrage du serveur..." -ForegroundColor Yellow
Write-Host "  [INFO] Demarrage du serveur en mode visible pour voir les erreurs..." -ForegroundColor Cyan
Write-Host "  [INFO] Appuyez sur Ctrl+C pour arreter" -ForegroundColor Yellow
Write-Host ""

# Créer le dossier logs s'il n'existe pas
$logsDir = Join-Path $backendPath "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Configuration
$waitressHost = [Environment]::GetEnvironmentVariable("WAITRESS_HOST", "Process")
if (-not $waitressHost) { $waitressHost = "0.0.0.0" }

$port = [Environment]::GetEnvironmentVariable("WAITRESS_PORT", "Process")
if (-not $port) { $port = [Environment]::GetEnvironmentVariable("FLASK_PORT", "Process") }
if (-not $port) { $port = "5000" }

[Environment]::SetEnvironmentVariable("FLASK_DEBUG", "false", "Process")

Write-Host "  Configuration:" -ForegroundColor Cyan
Write-Host "    Host: $waitressHost" -ForegroundColor Gray
Write-Host "    Port: $port" -ForegroundColor Gray
Write-Host ""

# Changer vers le répertoire backend
Push-Location $backendPath

try {
    # Lancer Waitress en mode visible
    $waitressCmd = Join-Path $backendPath ".venv\Scripts\waitress-serve.exe"
    if (Test-Path $waitressCmd) {
        & $waitressCmd `
            --host=$waitressHost `
            --port=$port `
            --threads=4 `
            --channel-timeout=120 `
            wsgi:application
    } else {
        & $venvPython -m waitress `
            --host=$waitressHost `
            --port=$port `
            --threads=4 `
            --channel-timeout=120 `
            wsgi:application
    }
} catch {
    Write-Host ""
    Write-Host "  [ERREUR] Erreur lors du demarrage:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

