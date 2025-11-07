@echo off
echo [INFO] Démarrage du backend Flask...
cd /d "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
if not exist "venv\Scripts\python.exe" (
    echo [ERREUR] Environnement virtuel non trouve ou incomplet
    pause
    exit /b 1
)
echo [OK] Utilisation de l'environnement virtuel Python 3.13
venv\Scripts\python.exe app.py
pause
