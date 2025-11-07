# 🔧 Résolution du problème d'accès au backend depuis le réseau

## Problème
Le backend Flask n'est pas accessible depuis un appareil Android via `http://192.168.0.121:5000`

## ✅ Solution en 3 étapes

### Étape 1 : Vérifier et lancer le backend Flask

**Vérifier si le backend est lancé :**
```powershell
cd backend
.\check_network_access.ps1
```

**Si le backend n'est pas lancé, le démarrer :**
```powershell
cd backend
.\start_backend.ps1
```

Ou si vous utilisez le script silencieux :
```powershell
cd backend
.\start_backend_silent.vbs
```

**Vérifier que le backend est bien lancé :**
- Ouvrez un navigateur sur votre PC
- Allez à : `http://localhost:5000/health`
- Vous devriez voir : `{"status":"healthy"}`

### Étape 2 : Configurer le pare-feu Windows

**⚠️ IMPORTANT :** Ce script nécessite des privilèges d'administrateur.

1. **Ouvrir PowerShell en tant qu'administrateur :**
   - Cliquez avec le bouton droit sur PowerShell
   - Sélectionnez "Exécuter en tant qu'administrateur"

2. **Naviguer vers le dossier backend :**
   ```powershell
   cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
   ```

3. **Exécuter le script de configuration du pare-feu :**
   ```powershell
   .\configure_firewall.ps1
   ```

Le script va créer une règle de pare-feu pour autoriser le trafic entrant sur le port 5000.

### Étape 3 : Trouver votre vraie IP Wi-Fi

**Méthode 1 : Via PowerShell**
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" -and $_.IPAddress -notlike "192.168.56.*" } | Select-Object IPAddress, InterfaceAlias
```

**Méthode 2 : Via l'interface Windows**
1. Ouvrez les Paramètres Windows
2. Aller à "Réseau et Internet" > "Wi-Fi"
3. Cliquez sur votre réseau Wi-Fi
4. Regardez "Adresse IPv4"

**Méthode 3 : Via la ligne de commande**
```powershell
ipconfig | findstr /i "IPv4"
```

## 🔍 Vérification

Une fois les 3 étapes terminées :

1. **Depuis votre PC :**
   ```powershell
   Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
   ```
   Devrait retourner : `{"status":"healthy"}`

2. **Depuis votre appareil Android (sur le même réseau Wi-Fi) :**
   - Ouvrez Chrome sur l'appareil
   - Allez à : `http://VOTRE_IP_WIFI:5000/health`
   - Exemple : `http://192.168.0.121:5000/health`
   - Devrait afficher : `{"status":"healthy"}`

## ❌ Si ça ne fonctionne toujours pas

### Vérifications supplémentaires :

1. **Le PC et l'appareil sont-ils sur le même réseau Wi-Fi ?**
   - Vérifiez que les deux sont connectés au même réseau

2. **Le backend écoute-t-il bien sur toutes les interfaces ?**
   - Vérifiez dans `backend/app.py` ligne 149 : `app.run(debug=debug, host="0.0.0.0", port=port)`
   - Doit être `host="0.0.0.0"` (pas `host="127.0.0.1"`)

3. **Le port 5000 est-il utilisé par autre chose ?**
   ```powershell
   netstat -ano | findstr :5000
   ```

4. **Le pare-feu Windows est-il vraiment configuré ?**
   ```powershell
   Get-NetFirewallRule -DisplayName "Flask Traffic Tracking Backend"
   ```

5. **Test depuis un autre appareil sur le même réseau :**
   - Essayez depuis un autre PC ou téléphone
   - Si ça fonctionne depuis un autre appareil, le problème vient de l'appareil Android

## 📝 Notes importantes

- **IP 192.168.56.x** : C'est généralement une interface virtuelle (VirtualBox, VMware). Ignorez-la.
- **IP 192.168.0.x ou 192.168.1.x** : C'est généralement votre vraie IP Wi-Fi
- Le backend doit être **lancé** pour être accessible
- Le pare-feu doit **autoriser** le port 5000
- Le PC et l'appareil doivent être sur le **même réseau Wi-Fi**

## 🚀 Script automatique

Vous pouvez aussi utiliser le script de vérification qui fait tout automatiquement :

```powershell
cd backend
.\check_network_access.ps1
```

Ce script vous dira exactement ce qui ne va pas et comment le corriger.


