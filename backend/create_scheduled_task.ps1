# Script pour créer la tâche planifiée de démarrage automatique
# Nécessite des privilèges d'administrateur

# Vérifier si le script est exécuté en tant qu'administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ATTENTION] Ce script nécessite des privilèges d'administrateur." -ForegroundColor Yellow
    Write-Host "Relancez PowerShell en tant qu'administrateur et réexécutez ce script." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ou cliquez avec le bouton droit sur PowerShell et sélectionnez 'Exécuter en tant qu'administrateur'." -ForegroundColor Cyan
    Write-Host ""
    $response = Read-Host "Voulez-vous relancer ce script avec les privilèges d'administrateur? (O/N)"
    if ($response -eq 'O' -or $response -eq 'o') {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    } else {
        exit 1
    }
}

$ErrorActionPreference = "Stop"

$taskName = "TrafficTrackingBackend"
$scriptPath = "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend\start_backend_background.vbs"
$workingDir = "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration du démarrage automatique" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Vérifier si le script existe
if (-not (Test-Path $scriptPath)) {
    Write-Host "[ERREUR] Le script n'existe pas: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Script trouvé: $scriptPath" -ForegroundColor Green

# Charger l'assembly Task Scheduler
try {
    $null = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Win32.TaskScheduler")
} catch {
    Write-Host "[INFO] Tentative d'utilisation de schtasks en mode alternatif..." -ForegroundColor Yellow
}

# Méthode 1: Utiliser l'API .NET (si disponible)
try {
    $service = New-Object -ComObject Schedule.Service
    $service.Connect()
    
    $rootFolder = $service.GetFolder("\")
    
    # Supprimer la tâche existante si elle existe
    try {
        $rootFolder.DeleteTask($taskName, 0)
        Write-Host "[INFO] Suppression de la tâche existante..." -ForegroundColor Yellow
    } catch {
        # La tâche n'existe pas, c'est normal
    }
    
    # Créer la nouvelle tâche
    $task = $service.NewTask(0)
    $task.RegistrationInfo.Description = "Démarrage automatique du backend Flask Traffic Tracking"
    $task.Settings.Enabled = $true
    $task.Settings.Hidden = $false
    $task.Settings.StartWhenAvailable = $true
    $task.Principal.RunLevel = 1  # TASK_RUNLEVEL_HIGHEST
    
    # Déclencheur: au démarrage
    $trigger = $task.Triggers.Create(8)  # TASK_TRIGGER_BOOT
    $trigger.Enabled = $true
    
    # Action: exécuter le script VBS (qui lance le BAT en arrière-plan)
    $action = $task.Actions.Create(0)  # TASK_ACTION_EXEC
    $action.Path = "wscript.exe"
    $action.Arguments = "`"$scriptPath`""
    $action.WorkingDirectory = $workingDir
    
    # Enregistrer la tâche
    $rootFolder.RegisterTaskDefinition($taskName, $task, 6, $null, $null, 1)
    
    Write-Host ""
    Write-Host "[SUCCÈS] Tâche planifiée créée avec succès!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Détails de la tâche:" -ForegroundColor Cyan
    Write-Host "  Nom: $taskName"
    Write-Host "  Déclencheur: Au démarrage de Windows"
    Write-Host "  Privilèges: Élevés"
    Write-Host "  Script: $scriptPath"
    Write-Host ""
    Write-Host "La tâche sera exécutée au prochain démarrage de Windows." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pour tester maintenant, exécutez:" -ForegroundColor Cyan
    Write-Host "  schtasks /run /TN `"$taskName`""
    Write-Host ""
    Write-Host "Pour vérifier la tâche:" -ForegroundColor Cyan
    Write-Host "  schtasks /query /TN `"$taskName`" /V /FO LIST"
    exit 0
} catch {
    Write-Host "[INFO] API .NET non disponible, utilisation de schtasks..." -ForegroundColor Yellow
    
    # Méthode 2: Utiliser schtasks avec un fichier XML temporaire
    $xmlPath = Join-Path $workingDir "task_definition.xml"
    
    # Créer le XML de la tâche
    $xmlContent = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-01-01T00:00:00</Date>
    <Description>Démarrage automatique du backend Flask Traffic Tracking</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>wscript.exe</Command>
      <Arguments>"$scriptPath"</Arguments>
      <WorkingDirectory>$workingDir</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@
    
    # Écrire le XML
    [System.IO.File]::WriteAllText($xmlPath, $xmlContent, [System.Text.Encoding]::Unicode)
    
    # Supprimer la tâche existante (ignorer les erreurs)
    try {
        $null = schtasks /delete /TN $taskName /F 2>&1
    } catch {
        # Ignorer si la tâche n'existe pas
    }
    
    # Créer la tâche à partir du XML
    $result = schtasks /create /TN $taskName /XML $xmlPath /F 2>&1
    $success = $LASTEXITCODE -eq 0
    
    # Supprimer le fichier XML temporaire
    Remove-Item $xmlPath -ErrorAction SilentlyContinue
    
    if ($success) {
        Write-Host ""
        Write-Host "[SUCCÈS] Tâche planifiée créée avec succès!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Détails de la tâche:" -ForegroundColor Cyan
        Write-Host "  Nom: $taskName"
        Write-Host "  Déclencheur: Au démarrage de Windows"
        Write-Host "  Privilèges: Élevés"
        Write-Host "  Script: $scriptPath"
        Write-Host ""
        Write-Host "La tâche sera exécutée au prochain démarrage de Windows." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Pour tester maintenant, exécutez:" -ForegroundColor Cyan
        Write-Host "  schtasks /run /TN `"$taskName`""
        Write-Host ""
        Write-Host "Pour vérifier la tâche:" -ForegroundColor Cyan
        Write-Host "  schtasks /query /TN `"$taskName`" /V /FO LIST"
    } else {
        Write-Host "[ERREUR] Échec de la création de la tâche." -ForegroundColor Red
        Write-Host "Erreur: $result" -ForegroundColor Red
        exit 1
    }
}
