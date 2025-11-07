# Script PowerShell pour generer le build Android APK (production)
# Usage: .\build_android_apk.ps1

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Build Android APK - Production" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

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

# Creer le dossier builds s'il n'existe pas
$buildsDir = Join-Path $scriptDir "builds"
if (-not (Test-Path $buildsDir)) {
    New-Item -ItemType Directory -Path $buildsDir | Out-Null
    Write-Host "[INFO] Dossier 'builds' cree" -ForegroundColor Green
}

Write-Host "[ETAPE 1/5] Nettoyage du build precedent..." -ForegroundColor Cyan
& $flutterPath clean
Write-Host "[OK] Nettoyage termine" -ForegroundColor Green
Write-Host ""

Write-Host "[ETAPE 2/5] Installation des dependances..." -ForegroundColor Cyan
& $flutterPath pub get
Write-Host "[OK] Dependances installees" -ForegroundColor Green
Write-Host ""

Write-Host "[ETAPE 3/5] Configuration de l'URL du backend..." -ForegroundColor Cyan

# Recuperer l'IP locale du PC pour l'APK de production
# Chercher les IPs dans les plages courantes (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
$allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    ($_.IPAddress -like "192.168.*" -or 
     $_.IPAddress -like "10.*" -or 
     $_.IPAddress -like "172.16.*" -or 
     $_.IPAddress -like "172.17.*" -or 
     $_.IPAddress -like "172.18.*" -or 
     $_.IPAddress -like "172.19.*" -or 
     $_.IPAddress -like "172.20.*" -or 
     $_.IPAddress -like "172.21.*" -or 
     $_.IPAddress -like "172.22.*" -or 
     $_.IPAddress -like "172.23.*" -or 
     $_.IPAddress -like "172.24.*" -or 
     $_.IPAddress -like "172.25.*" -or 
     $_.IPAddress -like "172.26.*" -or 
     $_.IPAddress -like "172.27.*" -or 
     $_.IPAddress -like "172.28.*" -or 
     $_.IPAddress -like "172.29.*" -or 
     $_.IPAddress -like "172.30.*" -or 
     $_.IPAddress -like "172.31.*") -and
    $_.IPAddress -notlike "127.*" -and
    $_.IPAddress -notlike "169.254.*"
} | Select-Object IPAddress, InterfaceAlias

# Chercher d'abord une IP Wi-Fi (priorite aux interfaces Wi-Fi)
$wifiIP = ($allIPs | Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*WLAN*" } | Select-Object -First 1).IPAddress

# Si pas trouve, chercher 192.168.0.x ou 10.x.x.x
if (-not $wifiIP) {
    $wifiIP = ($allIPs | Where-Object { 
        $_.IPAddress -like "192.168.0.*" -or 
        $_.IPAddress -like "10.*" 
    } | Select-Object -First 1).IPAddress
}

# Si toujours pas trouve, prendre la premiere IP qui n'est pas 192.168.56.x (VirtualBox)
if (-not $wifiIP) {
    $wifiIP = ($allIPs | Where-Object { $_.IPAddress -notlike "192.168.56.*" } | Select-Object -First 1).IPAddress
}

# Fallback vers une IP par defaut si rien trouve
if (-not $wifiIP) {
    Write-Host "[WARNING] Impossible de trouver l'IP locale. Utilisation de 192.168.0.121 par defaut." -ForegroundColor Yellow
    Write-Host "[INFO] Vous pourrez la modifier manuellement lors de la saisie" -ForegroundColor Cyan
    $localIP = "192.168.0.121"
} else {
    $localIP = $wifiIP
}

# Demander a l'utilisateur de confirmer ou modifier l'IP
Write-Host "[INFO] IP detectee: $localIP" -ForegroundColor Green
Write-Host "[INFO] URL du backend: http://$localIP`:5000" -ForegroundColor Cyan
Write-Host ""
$customIP = Read-Host "Appuyez sur Entree pour utiliser cette IP, ou entrez une autre IP/adresse (ex: 192.168.1.100 ou https://votre-serveur.com)"

if ($customIP -ne "") {
    # Valider que c'est une URL valide
    if ($customIP -match "^https?://") {
        $apiUrl = $customIP
        if ($apiUrl -notmatch ":\d+$") {
            $apiUrl = "$apiUrl`:5000"
        }
    } else {
        # Si c'est juste une IP, ajouter http:// et le port
        $apiUrl = "http://$customIP`:5000"
    }
} else {
    $apiUrl = "http://$localIP`:5000"
}

Write-Host "[INFO] URL du backend configuree: $apiUrl" -ForegroundColor Green
Write-Host "[INFO] Application ID: com.example.traffic_tracking_app" -ForegroundColor Yellow
Write-Host "[INFO] Assurez-vous que la signature est configuree dans android/app/build.gradle.kts" -ForegroundColor Yellow
Write-Host ""

Write-Host "[ETAPE 4/5] Generation du build APK..." -ForegroundColor Cyan
Write-Host "[INFO] Cela peut prendre plusieurs minutes..." -ForegroundColor Yellow
Write-Host "[INFO] Build avec URL du backend: $apiUrl" -ForegroundColor Cyan
Write-Host ""

# Generer le build APK avec l'URL du backend
& $flutterPath build apk --release --dart-define=API_BASE_URL=$apiUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Erreur lors de la generation du build APK" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Build APK genere avec succes!" -ForegroundColor Green
Write-Host ""

Write-Host "[ETAPE 5/5] Localisation du fichier APK..." -ForegroundColor Cyan

# Trouver le fichier APK genere
$apkPath = Join-Path $scriptDir "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    $apkSizeFormatted = "{0:N2}" -f $apkSize
    
    Write-Host "[OK] APK trouve: $apkPath" -ForegroundColor Green
    Write-Host "[INFO] Taille: $apkSizeFormatted MB" -ForegroundColor Cyan
    
    # Copier vers le dossier builds avec un nom descriptif
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $apkName = "traffic_tracking_app_v$timestamp.apk"
    $destinationPath = Join-Path $buildsDir $apkName
    Copy-Item $apkPath $destinationPath -Force
    Write-Host "[INFO] APK copie vers: $destinationPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Build termine avec succes!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fichier APK: $destinationPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Vous pouvez maintenant installer cet APK sur un appareil Android." -ForegroundColor Cyan
    Write-Host "Pour installer: adb install $destinationPath" -ForegroundColor Yellow
} else {
    Write-Host "[ERREUR] Fichier APK non trouve: $apkPath" -ForegroundColor Red
    exit 1
}

