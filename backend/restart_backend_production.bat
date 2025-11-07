@echo off
REM Script pour arrêter tous les processus Flask et relancer en mode PRODUCTION

echo [INFO] Arret des processus Flask existants...
cd /d "%~dp0"

REM Arrêter tous les processus qui utilisent le port 5000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5000" ^| findstr "LISTENING"') do (
    echo [INFO] Arret du processus PID %%a
    taskkill /PID %%a /F >nul 2>&1
)

REM Attendre un peu pour que les processus se terminent
timeout /t 3 >nul

echo [INFO] Demarrage en mode PRODUCTION...
echo [INFO] Le serveur sera lance en arriere-plan sans fenetre visible
echo.

REM Lancer le script VBS qui lance en arrière-plan
start_backend_background.vbs

echo [OK] Le backend a ete lance en mode PRODUCTION
echo [INFO] Consultez les logs dans: logs\backend.log
echo.
pause

