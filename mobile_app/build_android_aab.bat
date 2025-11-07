@echo off
echo [INFO] Generation du build Android AAB (Google Play Store)...
echo.

REM Naviguer dans le dossier du script
cd /d "%~dp0"

REM Executer le script PowerShell
powershell.exe -ExecutionPolicy Bypass -File "build_android_aab.ps1"

pause

