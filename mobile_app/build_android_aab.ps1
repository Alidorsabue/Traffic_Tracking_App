# Script PowerShell pour generer le build Android AAB (pour Google Play Store)
# Usage: .\build_android_aab.ps1
# 
# IMPORTANT: Pour publier sur Google Play Store, vous devez:
# 1. Configurer la signature de l'application dans android/app/build.gradle.kts
# 2. Creer un fichier keystore pour signer l'application
# 3. Mettre a jour le applicationId dans android/app/build.gradle.kts

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Build Android AAB - Production (Google Play Store)" -ForegroundColor Cyan
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

# Pour Google Play Store, demander l'URL du serveur de production
Write-Host "[INFO] Pour Google Play Store, vous devez specifier l'URL de votre serveur de production." -ForegroundColor Yellow
Write-Host "[INFO] Exemples:" -ForegroundColor Cyan
Write-Host "  - http://192.168.1.100:5000 (IP locale)" -ForegroundColor Cyan
Write-Host "  - https://votre-serveur.com (Serveur distant)" -ForegroundColor Cyan
Write-Host "  - https://api.votre-domaine.com:5000 (Serveur avec domaine)" -ForegroundColor Cyan
Write-Host ""

$apiUrl = Read-Host "Entrez l'URL du backend (ex: https://votre-serveur.com ou http://192.168.1.100:5000)"

# Valider et formater l'URL
if ($apiUrl -eq "") {
    Write-Host "[ERREUR] URL du backend requise pour le build AAB" -ForegroundColor Red
    exit 1
}

# Ajouter http:// si pas present
if ($apiUrl -notmatch "^https?://") {
    $apiUrl = "http://$apiUrl"
}

# Ajouter le port par defaut si pas specifie
if ($apiUrl -notmatch ":\d+$") {
    $apiUrl = "$apiUrl`:5000"
}

Write-Host "[INFO] URL du backend configuree: $apiUrl" -ForegroundColor Green
Write-Host "[INFO] Application ID: com.example.traffic_tracking_app" -ForegroundColor Yellow
Write-Host "[WARNING] IMPORTANT: Assurez-vous que la signature est configuree pour la production!" -ForegroundColor Red
Write-Host "[WARNING] Pour publier sur Google Play, vous devez signer l'application." -ForegroundColor Red
Write-Host ""

# Demander confirmation
$confirmation = Read-Host "Continuer avec le build AAB? (O/N)"
if ($confirmation -ne "O" -and $confirmation -ne "o") {
    Write-Host "Build annule." -ForegroundColor Yellow
    exit 0
}

Write-Host "[ETAPE 4/5] Generation du build AAB..." -ForegroundColor Cyan
Write-Host "[INFO] Cela peut prendre plusieurs minutes..." -ForegroundColor Yellow
Write-Host "[INFO] Build avec URL du backend: $apiUrl" -ForegroundColor Cyan
Write-Host ""

# Generer le build AAB avec l'URL du backend
& $flutterPath build appbundle --release --dart-define=API_BASE_URL=$apiUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Erreur lors de la generation du build AAB" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Build AAB genere avec succes!" -ForegroundColor Green
Write-Host ""

Write-Host "[ETAPE 5/5] Localisation du fichier AAB..." -ForegroundColor Cyan

# Trouver le fichier AAB genere
$aabPath = Join-Path $scriptDir "build\app\outputs\bundle\release\app-release.aab"

if (Test-Path $aabPath) {
    $aabSize = (Get-Item $aabPath).Length / 1MB
    $aabSizeFormatted = "{0:N2}" -f $aabSize
    
    Write-Host "[OK] AAB trouve: $aabPath" -ForegroundColor Green
    Write-Host "[INFO] Taille: $aabSizeFormatted MB" -ForegroundColor Cyan
    
    # Copier vers le dossier builds avec un nom descriptif
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $aabName = "traffic_tracking_app_v$timestamp.aab"
    $destinationPath = Join-Path $buildsDir $aabName
    Copy-Item $aabPath $destinationPath -Force
    Write-Host "[INFO] AAB copie vers: $destinationPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Build termine avec succes!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fichier AAB: $destinationPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Vous pouvez maintenant uploader ce fichier sur Google Play Console." -ForegroundColor Cyan
    Write-Host "URL: https://play.google.com/console" -ForegroundColor Yellow
} else {
    Write-Host "[ERREUR] Fichier AAB non trouve: $aabPath" -ForegroundColor Red
    exit 1
}

