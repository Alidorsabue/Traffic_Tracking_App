@echo off
REM Script batch pour lancer le diagnostic du serveur
REM Usage: .\check_server_status.bat

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -File "check_server_status.ps1"
pause

