# Script pour reconstruire et relancer l'application avec la bonne configuration
# Usage: .\rebuild_and_run.ps1

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Rebuild et relance de l'application Flutter" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Chemin Flutter
$flutterPath = "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"

# Verifier que Flutter existe
if (-not (Test-Path $flutterPath)) {
    Write-Host "[ERREUR] Flutter non trouve: $flutterPath" -ForegroundColor Red
    exit 1
}

# Naviguer dans le dossier mobile_app
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Recuperer l'IP locale du PC (exclure les IPs virtuelles comme 192.168.56.x)
# Preferer 192.168.0.x pour le reseau Wi-Fi
$allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object IPAddress, InterfaceAlias

# Chercher d'abord une IP 192.168.0.x (reseau Wi-Fi typique)
$localIP = ($allIPs | Where-Object { $_.IPAddress -like "192.168.0.*" } | Select-Object -First 1).IPAddress

# Si pas trouve, prendre la premiere IP 192.168.x.x qui n'est pas 192.168.56.x (VirtualBox)
if (-not $localIP) {
    $localIP = ($allIPs | Where-Object { $_.IPAddress -notlike "192.168.56.*" } | Select-Object -First 1).IPAddress
}

# Fallback vers 192.168.0.121 si rien trouve
if (-not $localIP) {
    Write-Host "[WARNING] Impossible de trouver l'IP locale. Utilisation de 192.168.0.121 par defaut." -ForegroundColor Yellow
    $localIP = "192.168.0.121"
}

Write-Host "[INFO] IP du backend: $localIP" -ForegroundColor Green
Write-Host "[INFO] Assurez-vous que le backend Flask est lance sur http://$localIP`:5000" -ForegroundColor Yellow
Write-Host ""

# Etape 1: Nettoyer le build
Write-Host "[ETAPE 1/4] Nettoyage du build Flutter..." -ForegroundColor Cyan
& $flutterPath clean
Write-Host "[OK] Nettoyage termine" -ForegroundColor Green
Write-Host ""

# Etape 2: Installer les dependances
Write-Host "[ETAPE 2/4] Installation des dependances..." -ForegroundColor Cyan
& $flutterPath pub get
Write-Host "[OK] Dependances installees" -ForegroundColor Green
Write-Host ""

# Etape 3: Detection des appareils
Write-Host "[ETAPE 3/4] Detection des appareils..." -ForegroundColor Cyan
& $flutterPath devices
Write-Host ""

# Etape 4: Lancer l'application
Write-Host "[ETAPE 4/4] Lancement de l'application avec API_BASE_URL=http://$localIP`:5000..." -ForegroundColor Cyan
Write-Host "[INFO] Vous verrez 'API: http://$localIP`:5000' en haut de l'ecran d'accueil" -ForegroundColor Yellow
Write-Host "[INFO] Appuyez sur 'q' pour quitter l'application" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Lancer avec la bonne IP
& $flutterPath run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://$localIP`:5000

