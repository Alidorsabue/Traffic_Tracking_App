@echo off
REM Script pour démarrage en arrière-plan sans fenêtre visible
REM Utilisé pour le démarrage automatique au démarrage de Windows
REM MODE PRODUCTION - Utilise Waitress au lieu du serveur de développement Flask

cd /d "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"

REM Créer le dossier logs s'il n'existe pas
if not exist "logs" mkdir logs

REM Vérifier si le port 5000 est déjà utilisé (indique que Flask est en cours)
netstat -an | find "5000" | find "LISTENING" >NUL
if not errorlevel 1 (
    echo [%date% %time%] [ALERTE] Flask semble deja en cours (port 5000 occupe) >> logs\backend.log
    REM Ne pas quitter, vérifier si c'est vraiment notre processus
)

REM Vérifier que l'environnement virtuel existe
if not exist ".venv\Scripts\python.exe" (
    REM Log l'erreur dans un fichier
    echo [%date% %time%] [ERREUR] Environnement virtuel non trouve (.venv\Scripts\python.exe) >> logs\backend_error.log
    exit /b 1
)

REM Vérifier que Waitress est installé
.venv\Scripts\python.exe -c "import waitress" 2>>logs\backend_error.log
if errorlevel 1 (
    echo [%date% %time%] [ERREUR] Waitress n'est pas installe >> logs\backend_error.log
    echo [%date% %time%] [INFO] Installation de Waitress... >> logs\backend.log
    .venv\Scripts\python.exe -m pip install waitress --quiet >> logs\backend.log 2>>logs\backend_error.log
    if errorlevel 1 (
        echo [%date% %time%] [ERREUR] Impossible d'installer Waitress >> logs\backend_error.log
        exit /b 1
    )
)

REM Charger les variables d'environnement depuis .env.production si existe, sinon .env
REM Utiliser PowerShell pour charger correctement les variables d'environnement
if exist ".env.production" (
    set ENV_FILE=.env.production
) else (
    set ENV_FILE=.env
    echo [%date% %time%] [WARNING] Fichier .env.production non trouve, utilisation de .env >> logs\backend.log
)

REM Charger les variables d'environnement avec PowerShell et les appliquer
if exist "%ENV_FILE%" (
    powershell.exe -Command "$env:ENV_FILE='%ENV_FILE%'; Get-Content $env:ENV_FILE | ForEach-Object { if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') { $name = $matches[1].Trim(); $value = $matches[2].Trim(); if ($name -and $value) { [Environment]::SetEnvironmentVariable($name, $value, 'Process') } } }" >nul 2>&1
)

REM S'assurer que FLASK_DEBUG est false pour la production
set FLASK_DEBUG=false
powershell.exe -Command "[Environment]::SetEnvironmentVariable('FLASK_DEBUG', 'false', 'Process')" >nul 2>&1

REM Configuration Waitress
if not defined WAITRESS_HOST set WAITRESS_HOST=0.0.0.0
if not defined WAITRESS_PORT (
    if defined FLASK_PORT (
        set WAITRESS_PORT=%FLASK_PORT%
    ) else (
        set WAITRESS_PORT=5000
    )
)
if not defined WAITRESS_THREADS set WAITRESS_THREADS=4
if not defined WAITRESS_CHANNEL_TIMEOUT set WAITRESS_CHANNEL_TIMEOUT=120

REM Vérifier que wsgi.py existe
if not exist "wsgi.py" (
    echo [%date% %time%] [ERREUR] Fichier wsgi.py non trouve >> logs\backend_error.log
    exit /b 1
)

REM Lancer le backend en mode PRODUCTION avec Waitress et rediriger les logs
echo [%date% %time%] [INFO] Demarrage du backend Flask en mode PRODUCTION... >> logs\backend.log
echo [%date% %time%] [INFO] Serveur: Waitress (WSGI) >> logs\backend.log
echo [%date% %time%] [INFO] Host: %WAITRESS_HOST% >> logs\backend.log
echo [%date% %time%] [INFO] Port: %WAITRESS_PORT% >> logs\backend.log
echo [%date% %time%] [INFO] Threads: %WAITRESS_THREADS% >> logs\backend.log

REM Utiliser waitress-serve.exe directement si disponible, sinon python -m waitress
REM Note: pas de --call, utiliser directement wsgi:application
if exist ".venv\Scripts\waitress-serve.exe" (
    .venv\Scripts\waitress-serve.exe --host=%WAITRESS_HOST% --port=%WAITRESS_PORT% --threads=%WAITRESS_THREADS% --channel-timeout=%WAITRESS_CHANNEL_TIMEOUT% wsgi:application >> logs\backend.log 2>> logs\backend_error.log
) else (
    .venv\Scripts\python.exe -m waitress --host=%WAITRESS_HOST% --port=%WAITRESS_PORT% --threads=%WAITRESS_THREADS% --channel-timeout=%WAITRESS_CHANNEL_TIMEOUT% wsgi:application >> logs\backend.log 2>> logs\backend_error.log
)

REM Si le script se termine, cela signifie une erreur
echo [%date% %time%] [ERREUR] Le backend s'est arrete de maniere inattendue >> logs\backend_error.log

