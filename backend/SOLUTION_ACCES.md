# ✅ Solution : Accès au backend depuis appareil Android

## 🎯 Problème identifié

Vous essayez d'accéder à `http://192.168.0.121:5000` mais votre PC a l'IP **`10.191.42.19`** sur le réseau Wi-Fi.

## 🔧 Solution en 3 étapes

### Étape 1 : Lancer le backend Flask

Le backend doit être **lancé** pour être accessible :

```powershell
cd backend
.\start_backend.ps1
```

**Vérifier que le backend est lancé :**
- Ouvrez un navigateur sur votre PC
- Allez à : `http://localhost:5000/health`
- Vous devriez voir : `{"status":"healthy"}`

### Étape 2 : Configurer le pare-feu Windows

**⚠️ IMPORTANT :** Exécutez PowerShell **en tant qu'administrateur**.

1. Cliquez avec le bouton droit sur PowerShell → "Exécuter en tant qu'administrateur"

2. Naviguez vers le dossier backend :
   ```powershell
   cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
   ```

3. Exécutez le script de configuration :
   ```powershell
   .\configure_firewall.ps1
   ```

### Étape 3 : Utiliser la bonne IP

**Votre IP Wi-Fi réelle : `10.191.42.19`**

**Depuis votre appareil Android (sur le même réseau Wi-Fi) :**
- Ouvrez Chrome sur l'appareil
- Allez à : `http://10.191.42.19:5000/health`
- Vous devriez voir : `{"status":"healthy"}`

## 📱 Pour générer l'APK avec la bonne IP

Lors de la génération de l'APK, utilisez cette IP :

```powershell
cd mobile_app
.\build_android_apk.bat
```

Quand le script demande l'IP, entrez : `10.191.42.19`

Ou utilisez directement :
```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://10.191.42.19:5000
```

## ✅ Vérification complète

### 1. Backend lancé et accessible localement
```powershell
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
```
Résultat attendu : `{"status":"healthy"}`

### 2. Pare-feu configuré
```powershell
Get-NetFirewallRule -DisplayName "Flask Traffic Tracking Backend"
```
Résultat attendu : Une règle active

### 3. Accessible depuis le réseau
Depuis votre appareil Android (même réseau Wi-Fi) :
- Chrome → `http://10.191.42.19:5000/health`
- Résultat attendu : `{"status":"healthy"}`

## 🔍 Si ça ne fonctionne toujours pas

1. **Vérifiez que le backend est bien lancé :**
   ```powershell
   netstat -ano | findstr :5000
   ```
   Devrait afficher que le port 5000 est en écoute

2. **Vérifiez que le PC et l'appareil sont sur le même réseau Wi-Fi**

3. **Testez depuis un autre appareil** pour confirmer que le problème vient de l'appareil Android spécifique

4. **Utilisez le script de diagnostic :**
   ```powershell
   cd backend
   .\check_network_access.ps1
   ```

## 📝 Notes importantes

- **IP Wi-Fi détectée : `10.191.42.19`** (pas 192.168.x.x)
- Cette IP peut changer si vous vous reconnectez au Wi-Fi
- Pour un APK de production, utilisez l'IP détectée au moment du build
- Le backend doit écouter sur `0.0.0.0` (déjà configuré dans `app.py`)


