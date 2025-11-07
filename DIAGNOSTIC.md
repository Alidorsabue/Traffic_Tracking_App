# Diagnostic et Solutions pour l'erreur TimeoutException

## Problèmes identifiés

1. **L'application utilise toujours `10.0.2.2` au lieu de l'IP du PC**
2. **La table `gps_points` n'existe peut-être pas encore dans PostgreSQL**
3. **Le pare-feu Windows peut bloquer la connexion**

## Solutions étape par étape

### Étape 1 : Vérifier que la table existe

**Dans pgAdmin :**
1. Connectez-vous à PostgreSQL
2. Naviguez : Databases → Traffic_Tracking → Schemas → public → Tables
3. Si la table `gps_points` n'existe pas, créez-la avec cette requête SQL :

```sql
CREATE TABLE IF NOT EXISTS gps_points (
    id SERIAL PRIMARY KEY,
    driver_id TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    speed DOUBLE PRECISION,
    timestamp TIMESTAMP NOT NULL
);
```

### Étape 2 : Vérifier le backend

**Tester le backend localement :**
```powershell
cd backend
.\.venv\Scripts\python test_connection.py
```

Si ça ne fonctionne pas, le backend a un problème.

### Étape 3 : Vérifier le pare-feu Windows

1. Ouvrez : Paramètres → Pare-feu Windows → Paramètres avancés
2. Règles de trafic entrant → Nouvelle règle
3. Type : Port → TCP → Port spécifique : 5000
4. Action : Autoriser la connexion
5. Appliquez à tous les profils

### Étape 4 : Relancer l'application avec la bonne IP

**IMPORTANT :** L'application doit être complètement arrêtée et relancée après modification du code.

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

# Arrêter l'app si elle tourne (appuyez sur 'q' dans le terminal Flutter)

# Reconstruire et relancer
& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://192.168.0.121:5000
```

### Étape 5 : Tester depuis votre téléphone

Sur votre téléphone Android, ouvrez Chrome et allez sur :
```
http://192.168.0.121:5000/health
```

Si ça fonctionne, le backend est accessible. Si non, vérifiez le pare-feu.

### Étape 6 : Vérifier les logs du backend

Quand vous cliquez sur "Start Tracking", regardez le terminal où tourne le backend. Vous devriez voir les requêtes entrantes.

## Vérification finale

1. ✅ Backend lancé (port 5000 en écoute)
2. ✅ Table `gps_points` créée dans PostgreSQL
3. ✅ Pare-feu Windows autorise le port 5000
4. ✅ App lancée avec `--dart-define=API_BASE_URL=http://192.168.0.121:5000`
5. ✅ Téléphone et PC sur le même réseau Wi-Fi

## Commande complète pour relancer l'app

```powershell
cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\mobile_app"

& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" clean
& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" pub get
& "C:\Users\Helpdesk\Downloads\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat" run -d adb-0854525327007136-zeTuTc._adb-tls-connect._tcp --dart-define=API_BASE_URL=http://192.168.0.121:5000
```

