# Fichier à placer dans le dossier de démarrage Windows

## Fichier CORRECT à utiliser

**`start_backend_background.vbs`**

Ce fichier lance le backend en **mode PRODUCTION** avec Waitress, sans fenêtre visible.

## Fichier à NE PAS utiliser

**`start_backend_silent.vbs`** - Ce fichier lance le backend en mode DÉVELOPPEMENT (ne pas utiliser)

## Instructions

### Méthode 1 : Copier manuellement

1. Ouvrez l'Explorateur de fichiers Windows
2. Appuyez sur `Win + R` et tapez : `shell:startup`
3. Appuyez sur Entrée (cela ouvre le dossier de démarrage)
4. **Supprimez** `start_backend_silent.vbs` s'il existe
5. **Copiez** le fichier `start_backend_background.vbs` depuis le dossier `backend` vers ce dossier de démarrage

### Méthode 2 : Utiliser PowerShell (recommandé)

Ouvrez PowerShell dans le dossier `backend` et exécutez :

```powershell
# Chemin du dossier de démarrage
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Supprimer l'ancien fichier s'il existe
$oldFile = Join-Path $startupPath "start_backend_silent.vbs"
if (Test-Path $oldFile) {
    Remove-Item $oldFile -Force
    Write-Host "[OK] Ancien fichier supprime" -ForegroundColor Green
}

# Copier le nouveau fichier
$sourceFile = Join-Path $PSScriptRoot "start_backend_background.vbs"
$destFile = Join-Path $startupPath "start_backend_background.vbs"
Copy-Item $sourceFile $destFile -Force

Write-Host "[OK] Fichier copie dans le dossier de demarrage" -ForegroundColor Green
Write-Host "Fichier: $destFile" -ForegroundColor Cyan
```

### Méthode 3 : Utiliser la tâche planifiée (recommandé pour production)

Au lieu de placer un fichier dans le dossier de démarrage, utilisez une tâche planifiée Windows :

```powershell
cd backend
.\create_scheduled_task.ps1
```

Cette méthode est plus robuste et permet un meilleur contrôle.

## 🔍 Vérification

Après avoir placé le fichier, redémarrez votre ordinateur et vérifiez :

### Méthode rapide : Script de diagnostic automatique

**Utilisez le script de diagnostic pour vérifier rapidement l'état du serveur :**

```powershell
cd backend
.\check_server_status.ps1
```

Ce script vérifie automatiquement :
- ✅ Si le port 5000 est en écoute
- ✅ Si les processus Python/Waitress sont actifs
- ✅ Si le serveur répond à `http://localhost:5000`
- ✅ Si l'endpoint `/health` fonctionne
- ✅ Les logs pour détecter les erreurs
- ✅ Si le fichier de démarrage automatique est présent

### Vérification manuelle

1. **Vérifier que le serveur est en mode production** :
   - Ouvrez `backend\logs\backend.log`
   - Vous devriez voir : `[INFO] Serveur: Waitress (WSGI)`
   - Vous ne devriez PAS voir : `Running in DEBUG mode`

2. **Vérifier qu'aucune fenêtre n'est visible** :
   - Le serveur doit tourner en arrière-plan sans fenêtre de commande

3. **Tester l'API** :
   - ⚠️ **IMPORTANT** : Utilisez `http://localhost:5000` ou `http://127.0.0.1:5000` dans votre navigateur
   - ❌ **NE PAS utiliser** `http://0.0.0.0:5000` - cette adresse est uniquement pour la configuration du serveur (écoute sur toutes les interfaces)
   - Vous devriez voir : `{"message": "Traffic Tracking API"}`

4. **Vérifier le port 5000** :
   ```powershell
   netstat -an | findstr ":5000" | findstr "LISTENING"
   ```
   Si rien n'apparaît, le serveur n'est pas démarré.

5. **Vérifier les processus Python** :
   ```powershell
   Get-Process python* -ErrorAction SilentlyContinue
   ```

## 🛠️ Dépannage

### Le serveur n'est pas accessible après redémarrage

Si `http://localhost:5000` ne fonctionne pas après avoir redémarré votre machine :

1. **Exécutez le script de diagnostic** :
   ```powershell
   cd backend
   .\check_server_status.ps1
   ```
   Cela vous indiquera exactement où est le problème.

2. **Vérifiez les logs d'erreur** :
   ```powershell
   # Voir les dernières erreurs
   Get-Content backend\logs\backend_error.log -Tail 20
   
   # Voir les derniers logs
   Get-Content backend\logs\backend.log -Tail 20
   ```

3. **Vérifiez que le fichier VBS est dans le dossier de démarrage** :
   ```powershell
   Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
   ```
   Vous devriez voir `start_backend_background.vbs`

4. **Vérifiez que PostgreSQL est démarré** :
   - Le serveur a besoin de PostgreSQL pour fonctionner
   - Vérifiez dans les services Windows ou démarrez PostgreSQL manuellement

5. **Testez le démarrage avec le script de diagnostic** :
   ```powershell
   cd backend
   .\test_startup.ps1
   ```
   Ce script démarre le serveur en mode visible pour voir toutes les erreurs en temps réel.

6. **Démarrez le serveur manuellement pour tester** :
   ```powershell
   cd backend
   .\start_backend_production.ps1
   ```
   Si cela fonctionne manuellement mais pas au démarrage, le problème vient du fichier VBS ou du démarrage automatique.

7. **Vérifiez les tâches planifiées** :
   ```powershell
   schtasks /query /FO LIST | findstr /I "Traffic"
   ```

8. **Arrêtez tous les processus et relancez** :
   ```powershell
   cd backend
   .\stop_backend.bat
   .\restart_backend_production.bat
   ```

### Le serveur se lance toujours en mode développement

1. Vérifiez quel fichier est dans le dossier de démarrage :
   ```powershell
   Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
   ```
   Assurez-vous que c'est `start_backend_background.vbs` et NON `start_backend_silent.vbs`

2. Supprimez l'ancien fichier et recopiez le bon :
   ```powershell
   $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
   Remove-Item (Join-Path $startupPath "start_backend_silent.vbs") -ErrorAction SilentlyContinue
   Copy-Item "backend\start_backend_background.vbs" $startupPath -Force
   ```

