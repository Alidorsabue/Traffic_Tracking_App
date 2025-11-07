@echo off
set BACKUP_DIR="C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\backups"
set PGPASSWORD=postgres

if not exist %BACKUP_DIR% mkdir %BACKUP_DIR%

for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set DATE=%%d-%%b-%%c
)
set FILENAME=backup_%DATE%.sql

echo [INFO] Sauvegarde PostgreSQL en cours...
"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -U postgres -F c -b -v -f "%BACKUP_DIR%\%FILENAME%" Traffic_Tracking
echo [INFO] Sauvegarde terminée : %FILENAME%
