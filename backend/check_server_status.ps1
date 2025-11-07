# Script de diagnostic pour vérifier si le serveur est accessible
# Usage: .\check_server_status.ps1

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC DU SERVEUR BACKEND" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

# 1. Vérifier si le port 5000 est en écoute
Write-Host "[1/6] Verification du port 5000..." -ForegroundColor Yellow
$port5000 = netstat -an | Select-String ":5000" | Select-String "LISTENING"
if ($port5000) {
    Write-Host "  [OK] Port 5000 est en ecoute" -ForegroundColor Green
    Write-Host "  Details: $port5000" -ForegroundColor Gray
} else {
    Write-Host "  [ERREUR] Port 5000 n'est PAS en ecoute" -ForegroundColor Red
    $allOk = $false
}
Write-Host ""

# 2. Vérifier les processus Python/Waitress
Write-Host "[2/6] Verification des processus Python..." -ForegroundColor Yellow
$pythonProcesses = Get-Process python* -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*backend*" -or $_.CommandLine -like "*waitress*" -or $_.CommandLine -like "*wsgi*" }
if ($pythonProcesses) {
    Write-Host "  [OK] Processus Python trouve(s):" -ForegroundColor Green
    $pythonProcesses | ForEach-Object {
        Write-Host "    - PID: $($_.Id) | Nom: $($_.ProcessName) | Chemin: $($_.Path)" -ForegroundColor Gray
    }
} else {
    # Vérifier tous les processus Python qui pourraient être le serveur
    $allPython = Get-Process python* -ErrorAction SilentlyContinue
    if ($allPython) {
        Write-Host "  [WARNING] Processus Python trouve(s) mais pas clairement associe au backend:" -ForegroundColor Yellow
        $allPython | ForEach-Object {
            Write-Host "    - PID: $($_.Id) | Nom: $($_.ProcessName)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [ERREUR] Aucun processus Python trouve" -ForegroundColor Red
        $allOk = $false
    }
}
Write-Host ""

# 3. Tester l'accessibilité HTTP
Write-Host "[3/6] Test d'accessibilite HTTP (http://localhost:5000)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] Serveur accessible!" -ForegroundColor Green
    Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host "  Reponse: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "  [ERREUR] Serveur NON accessible" -ForegroundColor Red
    Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
    $allOk = $false
}
Write-Host ""

# 4. Tester l'endpoint /health
Write-Host "[4/6] Test de l'endpoint /health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] Endpoint /health accessible!" -ForegroundColor Green
    Write-Host "  Reponse: $($healthResponse.Content)" -ForegroundColor Gray
} catch {
    Write-Host "  [WARNING] Endpoint /health non accessible" -ForegroundColor Yellow
    Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# 5. Vérifier les logs
Write-Host "[5/6] Verification des logs..." -ForegroundColor Yellow
$logsDir = Join-Path $PSScriptRoot "logs"
if (Test-Path $logsDir) {
    $backendLog = Join-Path $logsDir "backend.log"
    $errorLog = Join-Path $logsDir "backend_error.log"
    $vbsErrorLog = Join-Path $logsDir "vbs_error.log"
    
    if (Test-Path $backendLog) {
        Write-Host "  [OK] Fichier backend.log trouve" -ForegroundColor Green
        $lastLines = Get-Content $backendLog -Tail 5 -ErrorAction SilentlyContinue
        if ($lastLines) {
            Write-Host "  Dernieres lignes du log:" -ForegroundColor Cyan
            $lastLines | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        }
    } else {
        Write-Host "  [WARNING] Fichier backend.log non trouve" -ForegroundColor Yellow
        Write-Host "  [INFO] Cela peut indiquer que le serveur n'a jamais demarre" -ForegroundColor Gray
    }
    
    if (Test-Path $errorLog) {
        $errorLines = Get-Content $errorLog -Tail 10 -ErrorAction SilentlyContinue
        if ($errorLines) {
            Write-Host "  [ALERTE] Erreurs trouvees dans backend_error.log:" -ForegroundColor Red
            $errorLines | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
            $allOk = $false
        } else {
            Write-Host "  [OK] Aucune erreur dans backend_error.log" -ForegroundColor Green
        }
    }
    
    if (Test-Path $vbsErrorLog) {
        $vbsErrors = Get-Content $vbsErrorLog -Tail 10 -ErrorAction SilentlyContinue
        if ($vbsErrors) {
            Write-Host "  [ALERTE] Erreurs trouvees dans vbs_error.log:" -ForegroundColor Red
            Write-Host "  [INFO] Le fichier VBS n'a pas pu lancer le serveur" -ForegroundColor Yellow
            $vbsErrors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
            $allOk = $false
        }
    }
} else {
    Write-Host "  [WARNING] Dossier logs non trouve" -ForegroundColor Yellow
    Write-Host "  [INFO] Le serveur n'a probablement jamais demarre" -ForegroundColor Gray
}
Write-Host ""

# 6. Vérifier le fichier de démarrage automatique
Write-Host "[6/6] Verification du demarrage automatique..." -ForegroundColor Yellow
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$vbsFile = Join-Path $startupPath "start_backend_background.vbs"
if (Test-Path $vbsFile) {
    Write-Host "  [OK] Fichier de demarrage automatique trouve: $vbsFile" -ForegroundColor Green
} else {
    Write-Host "  [WARNING] Fichier de demarrage automatique NON trouve" -ForegroundColor Yellow
    Write-Host "  Chemin attendu: $vbsFile" -ForegroundColor Gray
    Write-Host "  Le serveur ne demarrera pas automatiquement au prochain redemarrage" -ForegroundColor Yellow
}
Write-Host ""

# Résumé
Write-Host "============================================================" -ForegroundColor Cyan
if ($allOk) {
    Write-Host "RESUME: Serveur OK" -ForegroundColor Green
} else {
    Write-Host "RESUME: Problemes detectes" -ForegroundColor Red
    Write-Host ""
    Write-Host "Actions recommandees:" -ForegroundColor Yellow
    Write-Host "  1. Verifier les logs: backend\logs\backend_error.log" -ForegroundColor Cyan
    Write-Host "  2. Redemarrer le serveur manuellement:" -ForegroundColor Cyan
    Write-Host "     cd backend" -ForegroundColor Gray
    Write-Host "     .\start_backend_production.ps1" -ForegroundColor Gray
    Write-Host "  3. Verifier que le fichier VBS est dans le dossier de demarrage" -ForegroundColor Cyan
    Write-Host "  4. Verifier que PostgreSQL est demarre" -ForegroundColor Cyan
}
Write-Host "============================================================" -ForegroundColor Cyan

