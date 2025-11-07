# Backend Traffic Tracking

API Flask pour le suivi du trafic en temps réel.

## Configuration

1. Créer un fichier `.env` à la racine du dossier `backend` avec le contenu suivant :

```
DB_HOST=localhost
DB_PORT=5433
DB_NAME=Traffic_Tracking
DB_USER=postgres
DB_PASSWORD=postgres
DB_MAINTENANCE_DB=postgres

FLASK_PORT=5000
FLASK_DEBUG=true
```

2. Installer les dépendances :

```powershell
# Créer l'environnement virtuel (si pas déjà fait)
py -3 -m venv .venv

# Activer l'environnement virtuel
.\.venv\Scripts\Activate.ps1

# Installer les dépendances
pip install -r requirements.txt
```

## Démarrage

### Option 1 : Script PowerShell
```powershell
.\start_backend.ps1
```

### Option 2 : Commande manuelle
```powershell
.\.venv\Scripts\python app.py
```

## Initialisation de la base de données

Une fois le serveur démarré, initialiser la table dans PostgreSQL :

```powershell
Invoke-WebRequest -Method POST http://localhost:5000/init_db
```

Ou depuis un navigateur : `http://localhost:5000/init_db` (POST)

## Endpoints

- `GET /` - Page d'accueil de l'API
- `GET /health` - Vérification de l'état de santé (DB + serveur)
- `POST /init_db` - Initialisation de la table `gps_points`
- `POST /send_gps` - Envoi de données GPS
- `GET /get_points` - Récupération des points GPS (limite 100)

## Exemple d'utilisation

### Envoyer des données GPS
```bash
curl -X POST http://localhost:5000/send_gps \
  -H "Content-Type: application/json" \
  -d '{"latitude": 48.8566, "longitude": 2.3522, "speed": 50.5, "driver_id": "driver1"}'
```

### Récupérer les points
```bash
curl http://localhost:5000/get_points
```

