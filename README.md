# 🚗 Traffic Tracking App

Application complète de suivi du trafic en temps réel avec backend Flask (Python) et application mobile Flutter (Android/iOS). Le système permet de tracker la position GPS des véhicules, d'enregistrer les données dans une base PostgreSQL et de visualiser les points sur une carte Google Maps.

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Structure du projet](#structure-du-projet)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Démarrage](#démarrage)
- [Scripts disponibles](#scripts-disponibles)
- [Builds de production](#builds-de-production)
- [API Backend](#api-backend)
- [Fonctionnalités](#fonctionnalités)
- [Résolution de problèmes](#résolution-de-problèmes)
- [Documentation complémentaire](#documentation-complémentaire)

---

## 🎯 Vue d'ensemble

### Architecture

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────────┐
│  Application    │  HTTP   │   Backend    │   SQL   │   PostgreSQL    │
│  Mobile Flutter │◄───────►│  Flask (API) │◄───────►│   (Base de      │
│  (Android/iOS)  │         │   Python     │         │    données)     │
└─────────────────┘         └──────────────┘         └─────────────────┘
       │                            │
       │                            │
       ▼                            ▼
   Google Maps                 Logs & Monitoring
```

### Fonctionnalités principales

- 📍 **Tracking GPS en temps réel** : Enregistrement automatique de la position toutes les 10 secondes
- 🗺️ **Visualisation sur carte** : Affichage des points GPS sur Google Maps
- 📊 **API REST complète** : Endpoints pour envoyer/récupérer les données GPS
- 🔐 **Gestion des utilisateurs** : Identification par numéro de téléphone
- 📱 **Multi-plateforme** : Android, iOS, Windows Desktop
- 🌐 **Accès réseau** : Accessible depuis le réseau local ou Internet

---

## 📁 Structure du projet

```
Traffic_tracking_app/
├── backend/                          # Backend Flask (API)
│   ├── app.py                        # Application Flask principale
│   ├── requirements.txt              # Dépendances Python
│   ├── init_database.py             # Script d'initialisation de la base
│   ├── .env                         # Configuration (à créer)
│   ├── .venv/                       # Environnement virtuel Python
│   │
│   ├── Scripts de démarrage/
│   │   ├── start_backend.ps1        # Script PowerShell principal
│   │   ├── start_backend.bat        # Script batch Windows
│   │   ├── start_backend_silent.vbs # Démarrage silencieux en arrière-plan
│   │   └── start_backend_background.bat
│   │
│   ├── Scripts de configuration/
│   │   ├── configure_firewall.ps1   # Configuration du pare-feu Windows
│   │   ├── check_network_access.ps1 # Vérification de l'accessibilité
│   │   └── create_scheduled_task.ps1 # Démarrage automatique au boot
│   │
│   ├── Scripts utilitaires/
│   │   ├── init_database.py         # Initialisation de la base
│   │   ├── create_table.py          # Création de table
│   │   ├── create_table_interactive.py
│   │   └── test_connection.py       # Test de connexion
│   │
│   └── Documentation/
│       ├── README.md                # Documentation backend
│       ├── INIT_DATABASE.md         # Guide d'initialisation
│       ├── SCRIPTS.md               # Documentation des scripts
│       ├── CONFIGURER_DEMARRAGE_AUTO.md
│       ├── SOLUTION_ACCES.md        # Solution problèmes d'accès
│       └── RESOLUTION_PROBLEME_ACCES.md
│
├── mobile_app/                       # Application Flutter
│   ├── lib/
│   │   ├── main.dart                # Point d'entrée
│   │   ├── screens/
│   │   │   ├── home_screen.dart     # Écran d'accueil
│   │   │   └── map_screen.dart      # Écran de carte
│   │   └── services/
│   │       ├── api_service.dart     # Service API
│   │       └── phone_service.dart   # Service téléphone
│   │
│   ├── android/                     # Configuration Android
│   ├── ios/                         # Configuration iOS
│   ├── windows/                     # Configuration Windows
│   ├── assets/                      # Images et ressources
│   │
│   ├── Scripts de lancement/
│   │   ├── run_app.ps1              # Lancer sur Android (détecte émulateur/appareil)
│   │   ├── run_app_windows.ps1      # Lancer sur Windows Desktop
│   │   ├── lancer_app_windows.bat   # Lanceur batch Windows
│   │   └── rebuild_and_run.ps1      # Rebuild complet + lancement
│   │
│   ├── Scripts de build/
│   │   ├── build_android_apk.ps1    # Générer APK Android
│   │   ├── build_android_apk.bat    # Lanceur batch APK
│   │   ├── build_android_aab.ps1    # Générer AAB (Google Play)
│   │   ├── build_android_aab.bat    # Lanceur batch AAB
│   │   └── build_ios.sh             # Générer IPA iOS (Mac)
│   │
│   ├── builds/                      # Builds générés (APK/AAB/IPA)
│   │
│   └── Documentation/
│       ├── README.md                # Documentation mobile
│       ├── BUILD_PRODUCTION.md      # Guide de build production
│       ├── CONFIGURATION_URL_BACKEND.md
│       ├── LANCER_APP.md            # Guide de lancement
│       └── RELANCER_APP.md          # Guide de relancement
│
└── README.md                        # Ce fichier (documentation principale)
```

---

## 🛠️ Prérequis

### Backend

- **Python 3.8+** (recommandé : Python 3.13)
- **PostgreSQL** (version 12+) sur le port 5433 par défaut
- **pip** (gestionnaire de paquets Python)
- **Windows 10/11** (pour les scripts PowerShell)

### Application Mobile

- **Flutter SDK 3.0+** (recommandé : 3.29.3)
- **Android Studio** (pour développement Android)
- **Xcode** (pour développement iOS, macOS uniquement)
- **Clé API Google Maps** (pour Android et iOS)

### Réseau

- **Accès réseau local** : PC et appareils mobiles sur le même réseau Wi-Fi
- **Pare-feu Windows** : Port 5000 doit être ouvert (configuré automatiquement)

---

## 📦 Installation

### Backend

#### 1. Préparer l'environnement

```powershell
cd backend
```

#### 2. Créer l'environnement virtuel Python

```powershell
py -3 -m venv .venv
```

#### 3. Activer l'environnement virtuel

```powershell
.\.venv\Scripts\Activate.ps1
```

Si vous obtenez une erreur d'exécution de scripts, exécutez :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 4. Installer les dépendances

```powershell
pip install -r requirements.txt
```

Les dépendances installées sont :
- `flask==3.0.0` : Framework web
- `flask-cors==4.0.0` : Gestion CORS
- `psycopg[binary]>=3.2.0` : Driver PostgreSQL
- `python-dotenv==1.0.1` : Gestion des variables d'environnement

#### 5. Créer le fichier de configuration `.env`

Créez un fichier `.env` à la racine du dossier `backend` avec le contenu suivant :

```env
# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5433
DB_NAME=Traffic_Tracking
DB_USER=postgres
DB_PASSWORD=postgres
DB_MAINTENANCE_DB=postgres

# Configuration Flask
FLASK_PORT=5000
FLASK_DEBUG=true
```

**⚠️ Important** : Modifiez les valeurs selon votre configuration PostgreSQL.

#### 6. Initialiser la base de données

```powershell
python init_database.py
```

Ou de manière interactive :
```powershell
python create_table_interactive.py
```

#### 7. Vérifier la connexion

```powershell
python test_connection.py
```

### Application Mobile

#### 1. Naviguer dans le dossier mobile_app

```powershell
cd mobile_app
```

#### 2. Installer les dépendances Flutter

```powershell
flutter pub get
```

#### 3. Configurer la clé API Google Maps

**Pour Android :**

1. Obtenez une clé API Google Maps sur [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Ouvrez le fichier `android/app/src/main/AndroidManifest.xml`
3. Remplacez `YOUR_GOOGLE_MAPS_API_KEY` par votre clé :

```xml
<meta-data 
    android:name="com.google.android.geo.API_KEY" 
    android:value="VOTRE_CLE_API_ICI" />
```

**Pour iOS :**

1. Ajoutez votre clé API dans `ios/Runner/AppDelegate.swift` ou `Info.plist`
2. Configurez les permissions de localisation dans `Info.plist`

#### 4. Vérifier la configuration Flutter

```powershell
flutter doctor
```

---

## 🚀 Démarrage

### Backend

#### Option 1 : Script PowerShell (recommandé)

```powershell
cd backend
.\start_backend.ps1
```

#### Option 2 : Script batch

```powershell
cd backend
.\start_backend.bat
```

#### Option 3 : Démarrage silencieux (arrière-plan)

Double-cliquez sur `start_backend_silent.vbs` ou exécutez :
```powershell
cd backend
.\start_backend_silent.vbs
```

#### Option 4 : Commande manuelle

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
python app.py
```

#### Vérification

Le backend est lancé si vous voyez :
```
 * Running on http://127.0.0.1:5000
 * Running on http://10.191.42.19:5000
```

Testez l'endpoint de santé :
```powershell
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
```

### Application Mobile

#### Sur Windows Desktop

```powershell
cd mobile_app
.\lancer_app_windows.bat
```

Ou directement :
```powershell
flutter run -d windows
```

#### Sur Android (Émulateur ou Appareil)

**Le script détecte automatiquement l'environnement :**

```powershell
cd mobile_app
.\run_app.ps1
```

Le script va :
- Détecter si c'est un émulateur ou un appareil physique
- Utiliser `10.0.2.2` pour un émulateur
- Détecter automatiquement l'IP Wi-Fi pour un appareil physique
- Configurer l'URL du backend automatiquement

**Pour un appareil spécifique :**

```powershell
flutter devices  # Lister les appareils disponibles
flutter run -d <device-id> --dart-define=API_BASE_URL=http://VOTRE_IP:5000
```

---

## ⚙️ Configuration

### Configuration du réseau et pare-feu

#### 1. Configurer le pare-feu Windows

**⚠️ Nécessite des privilèges d'administrateur**

1. Ouvrez PowerShell **en tant qu'administrateur**
2. Naviguez vers le dossier backend :
   ```powershell
   cd "C:\Users\Helpdesk\OneDrive - AITS\Bureau\MASTER IA DATA SCIENCE DIT\RECHERCHES\Traffic_tracking_app\backend"
   ```
3. Exécutez le script :
   ```powershell
   .\configure_firewall.ps1
   ```

Ce script crée une règle de pare-feu pour autoriser le port 5000.

#### 2. Vérifier l'accessibilité réseau

```powershell
cd backend
.\check_network_access.ps1
```

Ce script vérifie :
- L'IP locale du PC
- Si le backend est lancé
- Si le pare-feu est configuré
- Si le port 5000 est en écoute

#### 3. Trouver votre IP Wi-Fi

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    ($_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*") -and
    $_.InterfaceAlias -like "*Wi-Fi*"
} | Select-Object IPAddress, InterfaceAlias
```

### Configuration de l'URL du backend

L'URL du backend est configurée au **build time** via `--dart-define=API_BASE_URL`.

**Pour un émulateur Android :**
- URL : `http://10.0.2.2:5000` (détecté automatiquement)

**Pour un appareil physique :**
- URL : `http://VOTRE_IP_WIFI:5000` (détecté automatiquement)

**Pour la production :**
- URL : `https://votre-serveur.com:5000` (à spécifier lors du build)

### Configuration du démarrage automatique

Pour démarrer le backend automatiquement au démarrage de Windows :

```powershell
cd backend
.\create_scheduled_task.ps1
```

**⚠️ Nécessite des privilèges d'administrateur**

---

## 📜 Scripts disponibles

### Backend

| Script | Description | Usage |
|--------|-------------|-------|
| `start_backend.ps1` | Démarre le backend Flask | `.\start_backend.ps1` |
| `start_backend.bat` | Version batch du démarrage | `.\start_backend.bat` |
| `start_backend_silent.vbs` | Démarre en arrière-plan (silencieux) | Double-clic ou `.\start_backend_silent.vbs` |
| `configure_firewall.ps1` | Configure le pare-feu Windows | `.\configure_firewall.ps1` (admin) |
| `check_network_access.ps1` | Vérifie l'accessibilité réseau | `.\check_network_access.ps1` |
| `create_scheduled_task.ps1` | Configure le démarrage automatique | `.\create_scheduled_task.ps1` (admin) |
| `test_connection.py` | Teste la connexion au backend | `python test_connection.py` |
| `init_database.py` | Initialise la base de données | `python init_database.py` |

### Application Mobile

| Script | Description | Usage |
|--------|-------------|-------|
| `run_app.ps1` | Lance sur Android (détecte émulateur/appareil) | `.\run_app.ps1` |
| `run_app_windows.ps1` | Lance sur Windows Desktop | `.\run_app_windows.ps1` |
| `lancer_app_windows.bat` | Lanceur batch Windows | `.\lancer_app_windows.bat` |
| `rebuild_and_run.ps1` | Rebuild complet + lancement | `.\rebuild_and_run.ps1` |
| `build_android_apk.ps1` | Génère APK Android | `.\build_android_apk.ps1` |
| `build_android_aab.ps1` | Génère AAB (Google Play) | `.\build_android_aab.ps1` |
| `build_ios.sh` | Génère IPA iOS (Mac) | `./build_ios.sh` |

---

## 📱 Builds de production

### Android APK (Installation directe)

```powershell
cd mobile_app
.\build_android_apk.bat
```

Le script va :
1. Détecter automatiquement votre IP Wi-Fi
2. Vous demander de confirmer ou modifier l'IP
3. Générer l'APK avec l'URL du backend configurée
4. Copier l'APK dans le dossier `builds/`

**Installation :**
```powershell
adb install builds\traffic_tracking_app_v[timestamp].apk
```

### Android AAB (Google Play Store)

```powershell
cd mobile_app
.\build_android_aab.bat
```

**⚠️ Important pour Google Play :**
1. Configurez la signature de l'application (voir `BUILD_PRODUCTION.md`)
2. Spécifiez l'URL de votre serveur de production
3. Utilisez HTTPS pour la sécurité

### iOS IPA (App Store)

**⚠️ Nécessite macOS et Xcode**

```bash
cd mobile_app
./build_ios.sh
```

Voir `mobile_app/BUILD_PRODUCTION.md` pour les détails complets.

### Documentation complète

Consultez `mobile_app/BUILD_PRODUCTION.md` pour :
- Configuration de la signature Android
- Configuration des certificats iOS
- Checklist avant publication
- Guide de publication sur les stores

---

## 🔌 API Backend

### Endpoints disponibles

#### `GET /`
Page d'accueil de l'API

**Réponse :**
```json
{
  "message": "Traffic Tracking API"
}
```

#### `GET /health`
Vérification de l'état de santé (base de données + serveur)

**Réponse (succès) :**
```json
{
  "status": "healthy"
}
```

**Réponse (erreur) :**
```json
{
  "status": "unhealthy",
  "details": "error message"
}
```

#### `POST /init_db`
Initialise la table `gps_points` dans la base de données

**Exemple :**
```powershell
Invoke-WebRequest -Method POST http://localhost:5000/init_db -UseBasicParsing
```

#### `POST /send_gps`
Envoie des données GPS

**Body (JSON) :**
```json
{
  "latitude": 48.8566,
  "longitude": 2.3522,
  "speed": 50.5,
  "driver_id": "driver1",
  "phone_number": "0123456789"
}
```

**Exemple :**
```powershell
$body = @{
    latitude = 48.8566
    longitude = 2.3522
    speed = 50.5
    driver_id = "driver1"
    phone_number = "0123456789"
} | ConvertTo-Json

Invoke-WebRequest -Method POST http://localhost:5000/send_gps `
    -ContentType "application/json" `
    -Body $body
```

#### `GET /get_points`
Récupère les 100 derniers points GPS

**Réponse :**
```json
[
  {
    "id": 1,
    "driver_id": "driver1",
    "phone_number": "0123456789",
    "latitude": 48.8566,
    "longitude": 2.3522,
    "speed": 50.5,
    "timestamp": "2025-11-05T16:30:00Z"
  },
  ...
]
```

### Structure de la base de données

**Table : `gps_points`**

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | SERIAL PRIMARY KEY | Identifiant unique |
| `driver_id` | VARCHAR(255) | ID du conducteur (optionnel) |
| `phone_number` | VARCHAR(20) | Numéro de téléphone (optionnel) |
| `latitude` | DECIMAL(10, 8) | Latitude |
| `longitude` | DECIMAL(11, 8) | Longitude |
| `speed` | DECIMAL(6, 2) | Vitesse en km/h |
| `timestamp` | TIMESTAMP | Date et heure d'enregistrement |

---

## ✨ Fonctionnalités

### Application Mobile

- 🗺️ **Carte interactive** : Visualisation des points GPS sur Google Maps
- 📍 **Tracking automatique** : Enregistrement de la position toutes les 10 secondes
- 📱 **Identification** : Association des données à un numéro de téléphone
- 🔄 **Synchronisation** : Envoi automatique des données au backend
- 📊 **Historique** : Visualisation des points enregistrés
- 🎨 **Interface moderne** : Design Material Design 3

### Backend

- 🚀 **API REST** : Endpoints pour toutes les opérations
- 🔒 **CORS configuré** : Accès depuis n'importe quelle origine
- 💾 **Base de données** : Stockage PostgreSQL avec gestion des erreurs
- 🔍 **Santé système** : Endpoint de vérification de l'état
- 📝 **Logs** : Journalisation des erreurs et requêtes

---

## 🔧 Résolution de problèmes

### Backend non accessible depuis le réseau

**Symptôme :** `ERR_CONNECTION_TIMED_OUT` ou `TimeoutException`

**Solution :**

1. **Vérifier que le backend est lancé :**
   ```powershell
   Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
   ```

2. **Configurer le pare-feu :**
   ```powershell
   cd backend
   .\configure_firewall.ps1  # En tant qu'administrateur
   ```

3. **Vérifier l'IP Wi-Fi :**
   ```powershell
   cd backend
   .\check_network_access.ps1
   ```

4. **Utiliser la bonne IP :**
   - Émulateur : `http://10.0.2.2:5000`
   - Appareil physique : `http://VOTRE_IP_WIFI:5000`

Voir `backend/SOLUTION_ACCES.md` pour plus de détails.

### Erreur de connexion à la base de données

**Symptôme :** `psycopg.OperationalError` ou erreur de connexion PostgreSQL

**Solution :**

1. Vérifier que PostgreSQL est démarré
2. Vérifier les paramètres dans `.env`
3. Tester la connexion :
   ```powershell
   python init_database.py
   ```

### Application Flutter ne se connecte pas au backend

**Symptôme :** `Network error` ou `TimeoutException`

**Solution :**

1. Vérifier que le backend est lancé et accessible
2. Vérifier l'URL configurée dans l'application
3. Pour un appareil physique, utiliser l'IP Wi-Fi du PC
4. Vérifier que le PC et l'appareil sont sur le même réseau Wi-Fi

### Google Maps ne s'affiche pas

**Symptôme :** Carte blanche ou erreur Google Maps

**Solution :**

1. Vérifier que la clé API Google Maps est configurée dans `AndroidManifest.xml`
2. Vérifier que les permissions de localisation sont accordées
3. Vérifier que la clé API a les bonnes restrictions (application Android)

### ModuleNotFoundError au démarrage du backend

**Symptôme :** `ModuleNotFoundError: No module named 'flask'`

**Solution :**

1. Activer l'environnement virtuel :
   ```powershell
   .\.venv\Scripts\Activate.ps1
   ```
2. Réinstaller les dépendances :
   ```powershell
   pip install -r requirements.txt
   ```

### Port 5000 déjà utilisé

**Symptôme :** `Address already in use` ou port occupé

**Solution :**

1. Trouver le processus utilisant le port :
   ```powershell
   netstat -ano | findstr :5000
   ```
2. Arrêter le processus ou changer le port dans `.env` :
   ```env
   FLASK_PORT=5001
   ```

---

## 📚 Documentation complémentaire

### Backend

- `backend/README.md` : Documentation complète du backend
- `backend/INIT_DATABASE.md` : Guide d'initialisation de la base
- `backend/SCRIPTS.md` : Documentation de tous les scripts
- `backend/SOLUTION_ACCES.md` : Solution aux problèmes d'accès réseau
- `backend/RESOLUTION_PROBLEME_ACCES.md` : Guide de résolution de problèmes
- `backend/CONFIGURER_DEMARRAGE_AUTO.md` : Configuration du démarrage automatique

### Application Mobile

- `mobile_app/README.md` : Documentation de l'application mobile
- `mobile_app/BUILD_PRODUCTION.md` : Guide complet des builds de production
- `mobile_app/CONFIGURATION_URL_BACKEND.md` : Configuration de l'URL du backend
- `mobile_app/LANCER_APP.md` : Guide de lancement de l'application
- `mobile_app/RELANCER_APP.md` : Guide de relancement avec rebuild

### Projet global

- `DIAGNOSTIC.md` : Guide de diagnostic général

---

## 📝 Notes importantes

### Sécurité

- ⚠️ **Ne commitez jamais** le fichier `.env` avec des mots de passe réels
- ⚠️ **Utilisez HTTPS** en production
- ⚠️ **Configurez les restrictions** de clé API Google Maps
- ⚠️ **Protégez votre base de données** avec un mot de passe fort

### Performance

- Le backend Flask utilise le mode développement par défaut
- Pour la production, utilisez un serveur WSGI (Gunicorn, Waitress)
- La base de données stocke les 100 derniers points (modifiable dans le code)

### Réseau

- L'IP Wi-Fi peut changer lors de la reconnexion au réseau
- Pour un déploiement stable, utilisez une IP fixe ou un serveur avec domaine
- Le backend écoute sur `0.0.0.0` par défaut (accessible depuis le réseau)

---

## 🎓 Développement

### Technologies utilisées

**Backend :**
- Python 3.13
- Flask 3.0.0
- PostgreSQL (psycopg 3.2.12)
- Flask-CORS 4.0.0

**Frontend :**
- Flutter 3.29.3
- Dart 3.0+
- Google Maps Flutter 2.5.0
- Geolocator 10.1.0
- HTTP 1.1.0

### Structure du code

**Backend :**
- `app.py` : Application Flask principale avec tous les endpoints
- `init_database.py` : Initialisation et création de tables
- `test_connection.py` : Tests de connexion

**Mobile :**
- `lib/main.dart` : Point d'entrée et configuration de l'app
- `lib/screens/` : Écrans de l'application
- `lib/services/` : Services API et utilitaires

---

## 📄 Licence

Ce projet est un projet de recherche académique.

---

## 👥 Support

Pour toute question ou problème :

1. Consultez la documentation dans les dossiers `backend/` et `mobile_app/`
2. Vérifiez les fichiers de résolution de problèmes
3. Utilisez les scripts de diagnostic fournis

---

## 🚀 Améliorations futures

- [ ] Authentification utilisateur (JWT)
- [ ] Interface web d'administration
- [ ] Export des données (CSV, JSON)
- [ ] Notifications push
- [ ] Géofencing
- [ ] Historique des trajets
- [ ] Statistiques et analytics
- [ ] Mode hors ligne avec synchronisation

---
NEW SERVER 
DIGITALOCEAN SERVER
host : alidor-server
password : virgi@1996



**Dernière mise à jour :** Novembre 2025

**Version :** 1.0.0
