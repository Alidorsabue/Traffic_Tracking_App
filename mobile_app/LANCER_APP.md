# Instructions pour lancer l'application sur appareil Android

## Problème résolu
L'erreur "TimeoutException" était due à l'utilisation de `10.0.2.2` qui ne fonctionne que pour l'émulateur Android.

## Solution

### Option 1 : Utiliser le script automatique (RECOMMANDÉ)
Le script `run_app.ps1` détecte automatiquement l'IP de votre PC :

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"
.\run_app.ps1
```

### Option 2 : Commande manuelle avec IP spécifique
```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://192.168.0.121:5000
```

## Vérifications importantes

1. **Backend lancé** : Assurez-vous que le backend Flask est démarré :
   ```powershell
   cd backend
   .\start_backend.ps1
   ```

2. **Firewall Windows** : Si l'appareil ne se connecte toujours pas, vérifiez que le port 5000 est ouvert dans le pare-feu Windows :
   - Panneau de configuration > Pare-feu Windows > Paramètres avancés
   - Autoriser une application via le pare-feu
   - Vérifier que Python/Flask peut communiquer sur le réseau

3. **Même réseau Wi-Fi** : Votre appareil Android et votre PC doivent être sur le même réseau Wi-Fi.

## IP du PC
Votre PC a l'adresse IP : **192.168.0.121**

Si cette IP change, modifiez-la dans la commande ou dans le script.














