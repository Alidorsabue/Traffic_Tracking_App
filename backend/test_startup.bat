@echo off
REM Script batch pour lancer le test de démarrage
REM Usage: .\test_startup.bat

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "test_startup.ps1"


