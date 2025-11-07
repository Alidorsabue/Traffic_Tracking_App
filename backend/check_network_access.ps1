# Script PowerShell pour verifier l'accessibilite du backend depuis le reseau
# Usage: .\check_network_access.ps1

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Verification de l'accessibilite du backend Flask" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Recuperer l'IP locale du PC
Write-Host "[ETAPE 1/4] Detection de l'IP locale..." -ForegroundColor Cyan
$allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Select-Object IPAddress, InterfaceAlias

if ($allIPs.Count -eq 0) {
    Write-Host "[WARNING] Aucune IP locale 192.168.x.x trouvee" -ForegroundColor Yellow
    Write-Host "[INFO] Affichage de toutes les IPs disponibles:" -ForegroundColor Cyan
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" } | Select-Object IPAddress, InterfaceAlias | Format-Table
} else {
    Write-Host "[OK] IPs locales trouvees:" -ForegroundColor Green
    $allIPs | Format-Table IPAddress, InterfaceAlias
    
    # Chercher d'abord une IP 192.168.0.x
    $localIP = ($allIPs | Where-Object { $_.IPAddress -like "192.168.0.*" } | Select-Object -First 1).IPAddress
    
    if (-not $localIP) {
        $localIP = ($allIPs | Where-Object { $_.IPAddress -notlike "192.168.56.*" } | Select-Object -First 1).IPAddress
    }
    
    if ($localIP) {
        Write-Host "[INFO] IP principale detectee: $localIP" -ForegroundColor Green
    }
}

Write-Host ""

# 2. Verifier si le backend Flask est lance
Write-Host "[ETAPE 2/4] Verification du backend Flask..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Backend Flask est lance et accessible sur localhost:5000" -ForegroundColor Green
        Write-Host "[INFO] Reponse: $($response.Content)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[ERREUR] Backend Flask n'est pas accessible sur localhost:5000" -ForegroundColor Red
    Write-Host "[INFO] Assurez-vous que le backend est lance avec: .\start_backend.ps1" -ForegroundColor Yellow
}

Write-Host ""

# 3. Verifier la regle de pare-feu
Write-Host "[ETAPE 3/4] Verification de la regle de pare-feu..." -ForegroundColor Cyan
$firewallRule = Get-NetFirewallRule -DisplayName "Flask Traffic Tracking Backend" -ErrorAction SilentlyContinue

if ($firewallRule) {
    $ruleEnabled = ($firewallRule | Where-Object { $_.Enabled -eq $true })
    if ($ruleEnabled) {
        Write-Host "[OK] Regle de pare-feu trouvee et activee" -ForegroundColor Green
        $firewallRule | Format-Table DisplayName, Enabled, Direction, Action
    } else {
        Write-Host "[WARNING] Regle de pare-feu trouvee mais desactivee" -ForegroundColor Yellow
        Write-Host "[INFO] Executez: .\configure_firewall.ps1 (en tant qu'administrateur)" -ForegroundColor Cyan
    }
} else {
    Write-Host "[WARNING] Aucune regle de pare-feu trouvee pour le port 5000" -ForegroundColor Yellow
    Write-Host "[INFO] Pour autoriser l'acces depuis le reseau, executez:" -ForegroundColor Cyan
    Write-Host "      .\configure_firewall.ps1 (en tant qu'administrateur)" -ForegroundColor Yellow
}

Write-Host ""

# 4. Verifier que le port 5000 est ecoute
Write-Host "[ETAPE 4/4] Verification du port 5000..." -ForegroundColor Cyan
$portListen = Get-NetTCPConnection -LocalPort 5000 -State Listen -ErrorAction SilentlyContinue

if ($portListen) {
    Write-Host "[OK] Le port 5000 est en ecoute" -ForegroundColor Green
    $portListen | Format-Table LocalAddress, LocalPort, State, OwningProcess
} else {
    Write-Host "[WARNING] Le port 5000 n'est pas en ecoute" -ForegroundColor Yellow
    Write-Host "[INFO] Assurez-vous que le backend Flask est lance" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Resume" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if ($localIP) {
    Write-Host "URL a utiliser depuis un appareil sur le meme reseau:" -ForegroundColor Cyan
    Write-Host "  http://$localIP`:5000/health" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Si le backend n'est pas accessible:" -ForegroundColor Yellow
Write-Host "1. Verifiez que le backend est lance: .\start_backend.ps1" -ForegroundColor Cyan
Write-Host "2. Configurez le pare-feu: .\configure_firewall.ps1 (en tant qu'administrateur)" -ForegroundColor Cyan
Write-Host "3. Verifiez que le PC et l'appareil sont sur le meme reseau Wi-Fi" -ForegroundColor Cyan
Write-Host ""

