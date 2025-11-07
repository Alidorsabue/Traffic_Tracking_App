# Script PowerShell pour configurer le pare-feu Windows pour le backend Flask
# Usage: .\configure_firewall.ps1
# 
# IMPORTANT: Ce script necessite des privileges d'administrateur

$ErrorActionPreference = "Stop"

# Verifier les privileges d'administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERREUR] Ce script necessite des privileges d'administrateur!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Pour executer ce script:" -ForegroundColor Yellow
    Write-Host "1. Cliquez avec le bouton droit sur PowerShell" -ForegroundColor Cyan
    Write-Host "2. Selectionnez 'Executer en tant qu'administrateur'" -ForegroundColor Cyan
    Write-Host "3. Naviguez vers le dossier backend" -ForegroundColor Cyan
    Write-Host "4. Executez: .\configure_firewall.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Configuration du pare-feu Windows pour le backend Flask" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$port = 5000
$ruleName = "Flask Traffic Tracking Backend"

# Verifier si la regle existe deja
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "[INFO] Regle de pare-feu existante trouvee: $ruleName" -ForegroundColor Yellow
    $remove = Read-Host "Voulez-vous supprimer la regle existante et en creer une nouvelle? (O/N)"
    
    if ($remove -eq "O" -or $remove -eq "o") {
        Write-Host "[INFO] Suppression de la regle existante..." -ForegroundColor Cyan
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        Write-Host "[OK] Regle supprimee" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Conservation de la regle existante" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Regle actuelle:" -ForegroundColor Cyan
        Get-NetFirewallRule -DisplayName $ruleName | Format-Table DisplayName, Enabled, Direction, Action
        exit 0
    }
}

Write-Host "[ETAPE 1/2] Creation de la regle de pare-feu entrante..." -ForegroundColor Cyan

try {
    # Creer une regle de pare-feu pour autoriser le port 5000
    New-NetFirewallRule -DisplayName $ruleName `
        -Description "Autorise le trafic entrant sur le port $port pour le backend Flask Traffic Tracking" `
        -Direction Inbound `
        -LocalPort $port `
        -Protocol TCP `
        -Action Allow `
        -Enabled True | Out-Null
    
    Write-Host "[OK] Regle de pare-feu creee avec succes!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[ETAPE 2/2] Verification de la regle..." -ForegroundColor Cyan
    $rule = Get-NetFirewallRule -DisplayName $ruleName
    Write-Host "[OK] Regle active et configuree" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "Configuration terminee avec succes!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Details de la regle:" -ForegroundColor Cyan
    Write-Host "  Nom: $ruleName" -ForegroundColor Yellow
    Write-Host "  Port: $port" -ForegroundColor Yellow
    Write-Host "  Direction: Entrant (Inbound)" -ForegroundColor Yellow
    Write-Host "  Action: Autoriser" -ForegroundColor Yellow
    Write-Host "  Statut: Active" -ForegroundColor Green
    Write-Host ""
    Write-Host "Le backend Flask devrait maintenant etre accessible depuis le reseau local." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour tester, depuis un appareil sur le meme reseau:" -ForegroundColor Cyan
    Write-Host "  http://VOTRE_IP:5000/health" -ForegroundColor Yellow
    Write-Host ""
    
} catch {
    Write-Host "[ERREUR] Impossible de creer la regle de pare-feu" -ForegroundColor Red
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

