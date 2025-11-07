@echo off
REM Script pour arrêter tous les processus Flask/Waitress en cours

echo [INFO] Arret des processus Flask/Waitress...

REM Arrêter tous les processus Python qui utilisent le port 5000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5000" ^| findstr "LISTENING"') do (
    echo [INFO] Arret du processus PID %%a
    taskkill /PID %%a /F >nul 2>&1
)

REM Arrêter tous les processus python.exe liés à Flask/Waitress
REM Note: Cette commande arrêtera TOUS les processus Python - utilisez avec précaution
REM taskkill /IM python.exe /F >nul 2>&1

echo [OK] Processus arretes
timeout /t 2 >nul

