# Instructions pour RELANCER l'application avec la bonne configuration

## ⚠️ IMPORTANT : Rebuild complet requis

Si l'application ne fonctionne pas, il faut la reconstruire complètement car Flutter utilise le code en cache.

## Étapes à suivre

### 1. Arrêter l'application actuelle

Si l'app tourne, appuyez sur **'q'** dans le terminal Flutter pour l'arrêter.

### 2. Nettoyer le build Flutter

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" clean
```

### 3. Vérifier que le backend est lancé

Dans un autre terminal :
```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
.\start_backend.ps1
```

### 4. Relancer l'application avec la bonne IP

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://192.168.0.121:5000
```

OU utilisez le script automatique :
```powershell
.\run_app.ps1
```

## Vérification

Une fois l'app lancée, regardez l'écran d'accueil. Vous devriez voir en haut de l'écran :
```
API: http://192.168.0.121:5000
```

Si vous voyez `API: http://10.0.2.2:5000`, c'est que l'application utilise encore l'ancienne configuration.

## Si ça ne fonctionne toujours pas

### Test de connexion depuis le téléphone

Sur votre téléphone Android, ouvrez Chrome et testez :
```
http://192.168.0.121:5000/health
```

Si ça ne fonctionne pas :
- Vérifiez le pare-feu Windows (port 5000 doit être ouvert)
- Vérifiez que le PC et le téléphone sont sur le même réseau Wi-Fi

### Vérifier les logs du backend

Quand vous cliquez sur "Start Tracking", regardez le terminal où tourne le backend. Vous devriez voir des requêtes POST vers `/send_gps`.

## Commande complète (tout-en-un)

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

# Nettoyer
& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" clean

# Relancer avec la bonne IP
& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://192.168.0.121:5000
```

