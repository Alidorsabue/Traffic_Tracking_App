# Script pour tester le démarrage de Waitress et voir les erreurs
# Usage: .\test_waitress_startup.ps1

$ErrorActionPreference = "Continue"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "TEST DE DEMARRAGE WAITRESS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$backendPath = $PSScriptRoot
$pythonPath = Join-Path $backendPath ".venv\Scripts\python.exe"

# Vérifier Python
if (-not (Test-Path $pythonPath)) {
    Write-Host "[ERREUR] Python non trouve: $pythonPath" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Python: $pythonPath" -ForegroundColor Green
Write-Host ""

# Test 1: Vérifier que wsgi.py peut être importé
Write-Host "[TEST 1] Test d'importation de wsgi.py..." -ForegroundColor Yellow
try {
    $testImport = & $pythonPath -c "import sys; sys.path.insert(0, r'$backendPath'); from wsgi import application; print('OK - Import reussi')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Import reussi" -ForegroundColor Green
        Write-Host "  $testImport" -ForegroundColor Gray
    } else {
        Write-Host "  [ERREUR] Echec de l'import" -ForegroundColor Red
        Write-Host "  $testImport" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  [ERREUR] Exception lors de l'import: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 2: Vérifier que app.py peut être importé
Write-Host "[TEST 2] Test d'importation de app.py..." -ForegroundColor Yellow
try {
    $testApp = & $pythonPath -c "import sys; sys.path.insert(0, r'$backendPath'); from app import app; print('OK - App importee')" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] App importee avec succes" -ForegroundColor Green
        Write-Host "  $testApp" -ForegroundColor Gray
    } else {
        Write-Host "  [ERREUR] Echec de l'import de app" -ForegroundColor Red
        Write-Host "  $testApp" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  [ERREUR] Exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Vérifier la connexion à PostgreSQL (sans crash)
Write-Host "[TEST 3] Test de connexion a PostgreSQL..." -ForegroundColor Yellow
try {
    $testDB = & $pythonPath -c "import sys; sys.path.insert(0, r'$backendPath'); from app import get_connection; conn = get_connection(); print('OK - Connexion DB reussie'); conn.close()" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Connexion a PostgreSQL reussie" -ForegroundColor Green
        Write-Host "  $testDB" -ForegroundColor Gray
    } else {
        Write-Host "  [WARNING] Probleme de connexion a PostgreSQL" -ForegroundColor Yellow
        Write-Host "  $testDB" -ForegroundColor Yellow
        Write-Host "  [INFO] Le serveur peut demarrer mais les endpoints necessitant la DB echoueront" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  [WARNING] Exception lors de la connexion DB: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Lancer Waitress avec capture d'erreurs
Write-Host "[TEST 4] Demarrage de Waitress (5 secondes de test)..." -ForegroundColor Yellow
Write-Host "  [INFO] Le serveur va demarrer et s'arreter automatiquement apres 5 secondes" -ForegroundColor Cyan
Write-Host ""

Push-Location $backendPath

try {
    # Lancer Waitress en arrière-plan avec timeout
    $job = Start-Job -ScriptBlock {
        param($pythonPath, $backendPath)
        Set-Location $backendPath
        $waitressCmd = Join-Path $backendPath ".venv\Scripts\waitress-serve.exe"
        if (Test-Path $waitressCmd) {
            & $waitressCmd --host=0.0.0.0 --port=5000 --threads=4 --channel-timeout=120 wsgi:application 2>&1
        } else {
            & $pythonPath -m waitress --host=0.0.0.0 --port=5000 --threads=4 --channel-timeout=120 wsgi:application 2>&1
        }
    } -ArgumentList $pythonPath, $backendPath
    
    # Attendre 5 secondes
    Start-Sleep -Seconds 5
    
    # Vérifier si le port est en écoute
    $portCheck = netstat -an | Select-String ":5000" | Select-String "LISTENING"
    if ($portCheck) {
        Write-Host "  [OK] Port 5000 est en ecoute!" -ForegroundColor Green
        Write-Host "  $portCheck" -ForegroundColor Gray
        
        # Tester l'accès
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000" -Method GET -TimeoutSec 2 -ErrorAction Stop
            Write-Host "  [OK] Serveur accessible! Status: $($response.StatusCode)" -ForegroundColor Green
            Write-Host "  Reponse: $($response.Content)" -ForegroundColor Gray
        } catch {
            Write-Host "  [WARNING] Serveur en ecoute mais requete echouee: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [ERREUR] Port 5000 n'est PAS en ecoute" -ForegroundColor Red
        
        # Récupérer les erreurs du job
        $output = Receive-Job -Job $job
        if ($output) {
            Write-Host "  [INFO] Sortie de Waitress:" -ForegroundColor Cyan
            $output | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        }
    }
    
    # Arrêter le job
    Stop-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "  [ERREUR] Exception: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  $($_.ScriptStackTrace)" -ForegroundColor Red
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "FIN DU TEST" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

