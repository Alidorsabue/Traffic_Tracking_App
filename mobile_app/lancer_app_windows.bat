@echo off
echo [INFO] Lancement de l'application Flutter sur Windows Desktop...
echo.

REM Naviguer dans le dossier du script
cd /d "%~dp0"

REM Exécuter le script PowerShell
powershell.exe -ExecutionPolicy Bypass -File "run_app_windows.ps1"

pause


