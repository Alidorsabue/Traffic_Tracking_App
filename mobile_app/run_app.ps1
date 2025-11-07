# Script PowerShell pour lancer l'application Flutter
# Usage: .\run_app.ps1

$ErrorActionPreference = "Stop"

Write-Host "[INFO] Demarrage de l'application Flutter..." -ForegroundColor Green

# Chemin Flutter
$flutterPath = "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat"

# Verifier que Flutter existe
if (-not (Test-Path $flutterPath)) {
    Write-Host "[ERREUR] Flutter non trouve: $flutterPath" -ForegroundColor Red
    Write-Host "Verifiez le chemin d'installation de Flutter." -ForegroundColor Yellow
    exit 1
}

# Naviguer dans le dossier mobile_app
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "[INFO] Installation des dependances..." -ForegroundColor Cyan
& $flutterPath pub get

Write-Host "[INFO] Detection des appareils..." -ForegroundColor Cyan
& $flutterPath devices

# Determiner si c'est un emulateur ou un appareil physique
# Pour un emulateur Android, utiliser 10.0.2.2 qui pointe vers localhost du PC hote
# Pour un appareil physique, utiliser l'IP locale du PC

# Recuperer l'ID de l'appareil
$deviceId = "0854525327007136"

# Vérifier si c'est un émulateur en utilisant adb
$isEmulator = $false
try {
    $adbCheck = adb -s $deviceId shell getprop ro.kernel.qemu 2>&1
    if ($adbCheck -eq "1") {
        $isEmulator = $true
    }
} catch {
    # Si adb n'est pas disponible, essayer de détecter par le nom de l'appareil
    $deviceList = & $flutterPath devices
    if ($deviceList -match "emulator" -or $deviceList -match "sdk") {
        $isEmulator = $true
    }
}

if ($isEmulator) {
    # Pour un émulateur, utiliser 10.0.2.2 qui est l'adresse spéciale pour localhost du PC hôte
    $apiUrl = "http://10.0.2.2:5000"
    Write-Host "[INFO] Emulateur Android detecte - Utilisation de 10.0.2.2 pour acceder au backend local" -ForegroundColor Cyan
    Write-Host "[INFO] Le backend Flask doit etre lance sur http://127.0.0.1:5000" -ForegroundColor Yellow
} else {
    # Pour un appareil physique, utiliser l'IP locale du PC
    # Chercher les IPs dans les plages courantes (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
    $allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
        ($_.IPAddress -like "192.168.*" -or 
         $_.IPAddress -like "10.*" -or 
         ($_.IPAddress -like "172.*" -and $_.IPAddress -notlike "172.28.*")) -and
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*"
    } | Select-Object IPAddress, InterfaceAlias
    
    # Chercher d'abord une IP Wi-Fi (priorite aux interfaces Wi-Fi)
    $localIP = ($allIPs | Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*WLAN*" } | Select-Object -First 1).IPAddress
    
    # Si pas trouve, chercher 192.168.0.x ou 10.x.x.x
    if (-not $localIP) {
        $localIP = ($allIPs | Where-Object { 
            $_.IPAddress -like "192.168.0.*" -or 
            $_.IPAddress -like "10.*" 
        } | Select-Object -First 1).IPAddress
    }
    
    # Si toujours pas trouve, prendre la premiere IP qui n'est pas 192.168.56.x (VirtualBox)
    if (-not $localIP) {
        $localIP = ($allIPs | Where-Object { $_.IPAddress -notlike "192.168.56.*" } | Select-Object -First 1).IPAddress
    }
    
    # Fallback vers 192.168.0.121 si rien trouve
    if (-not $localIP) {
        Write-Host "[WARNING] Impossible de trouver l'IP locale. Utilisation de 192.168.0.121 par defaut." -ForegroundColor Yellow
        $localIP = "192.168.0.121"
    }
    
    $apiUrl = "http://$localIP`:5000"
    Write-Host "[INFO] Appareil physique detecte - IP du backend: $localIP" -ForegroundColor Cyan
}

Write-Host "[INFO] URL du backend: $apiUrl" -ForegroundColor Green
Write-Host "[INFO] Assurez-vous que le backend Flask est lance sur le port 5000" -ForegroundColor Yellow
Write-Host "[INFO] Lancement de l'application sur TECNO CI6..." -ForegroundColor Cyan
Write-Host "Appuyez sur 'q' pour quitter l'application" -ForegroundColor Yellow

# Lancer sur l'appareil Android avec l'URL appropriee
& $flutterPath run -d $deviceId --dart-define=API_BASE_URL=$apiUrl

