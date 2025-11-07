# Guide de démarrage rapide du serveur

## ⚠️ Adresses importantes

- **Pour démarrer le serveur** : Le serveur écoute sur `0.0.0.0:5000` (toutes les interfaces)
- **Pour accéder au serveur depuis votre navigateur** : Utilisez `http://localhost:5000` ou `http://127.0.0.1:5000`
- **❌ NE PAS utiliser** `http://0.0.0.0:5000` dans votre navigateur - cette adresse n'est pas valide pour les navigateurs

## 🚀 Démarrage du serveur

### Option 1 : Démarrage manuel (pour tester)

```powershell
cd backend
.\start_backend_production.ps1
```

Le serveur démarrera et restera actif dans la fenêtre PowerShell. Vous verrez les messages de démarrage.

### Option 2 : Démarrage en arrière-plan

```powershell
cd backend
.\start_backend_background.bat
```

Le serveur démarrera en arrière-plan sans fenêtre visible.

## ✅ Vérifier que le serveur est démarré

### Méthode 1 : Script de diagnostic automatique

```powershell
cd backend
.\check_server_status.ps1
```

### Méthode 2 : Vérification manuelle

1. **Vérifier le port 5000** :
   ```powershell
   netstat -an | findstr ":5000" | findstr "LISTENING"
   ```
   Si vous voyez une ligne avec `0.0.0.0:5000` ou `127.0.0.1:5000`, le serveur est démarré.

2. **Tester dans le navigateur** :
   - Ouvrez `http://localhost:5000`
   - Vous devriez voir : `{"message": "Traffic Tracking API"}`

3. **Tester avec PowerShell** :
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:5000" -Method GET
   ```

## 🔍 Dépannage

### Le serveur ne démarre pas

1. **Vérifiez les logs d'erreur** :
   ```powershell
   Get-Content backend\logs\backend_error.log -Tail 20
   ```

2. **Vérifiez que PostgreSQL est démarré** :
   - Le serveur a besoin de PostgreSQL pour fonctionner
   - Vérifiez dans les services Windows

3. **Vérifiez que l'environnement virtuel existe** :
   ```powershell
   Test-Path backend\.venv\Scripts\python.exe
   ```

4. **Testez le démarrage avec diagnostic** :
   ```powershell
   cd backend
   .\test_startup.ps1
   ```
   Ce script affiche toutes les erreurs en temps réel.

### Le serveur démarre mais n'est pas accessible

1. **Vérifiez que vous utilisez `localhost` et non `0.0.0.0`** :
   - ✅ Correct : `http://localhost:5000`
   - ❌ Incorrect : `http://0.0.0.0:5000`

2. **Vérifiez le pare-feu Windows** :
   ```powershell
   cd backend
   .\configure_firewall.ps1
   ```

3. **Vérifiez que le port 5000 n'est pas utilisé par un autre programme** :
   ```powershell
   netstat -ano | findstr ":5000"
   ```

## 📝 Notes importantes

- `0.0.0.0` signifie "écouter sur toutes les interfaces réseau" - c'est pour la configuration du serveur
- `localhost` ou `127.0.0.1` est l'adresse pour accéder au serveur depuis votre machine
- Pour accéder depuis un autre appareil sur le même réseau, utilisez l'adresse IP de votre PC (ex: `http://192.168.1.100:5000`)


