@echo off
REM Script de surveillance pour redémarrer le backend en mode PRODUCTION
REM Vérifie si Waitress (serveur de production) est en cours d'exécution
REM Si non, relance le backend en mode production

cd /d "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"

REM Créer le dossier logs s'il n'existe pas
if not exist "logs" mkdir logs

:loop
REM Vérifier si le port 5000 est en écoute (indique que le serveur est actif)
netstat -an | find "5000" | find "LISTENING" >nul
if errorlevel 1 (
    REM Le port n'est pas en écoute, le serveur est arrêté
    echo [%date% %time%] [ALERTE] Flask semble arrete. Redemarrage en mode PRODUCTION... >> logs\monitoring.log
    REM Lancer le script de production en arrière-plan
    start /B "" "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\start_backend_background.bat"
    REM Attendre un peu avant de vérifier à nouveau
    timeout /t 10 >nul
) else (
    REM Le serveur est actif, juste attendre
    timeout /t 60 >nul
)
goto loop
