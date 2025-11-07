@echo off
REM Script pour démarrer le backend en mode PRODUCTION
REM Peut être utilisé manuellement ou en arrière-plan

REM Naviguer dans le dossier du script
cd /d "%~dp0"

REM Vérifier si on doit lancer en arrière-plan (si appelé avec /B)
if "%1"=="/B" (
    REM Lancer en arrière-plan sans fenêtre
    start /B "" cmd /c "%~f0" /NOBG
    exit /b 0
)

if "%1"=="/NOBG" (
    REM Mode arrière-plan - rediriger vers logs
    if not exist "logs" mkdir logs
    powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "start_backend_production.ps1" >> logs\backend.log 2>> logs\backend_error.log
    exit /b 0
)

REM Mode interactif - afficher les messages
echo [INFO] Demarrage du backend en mode PRODUCTION...
echo.

REM Executer le script PowerShell
powershell.exe -ExecutionPolicy Bypass -File "start_backend_production.ps1"

