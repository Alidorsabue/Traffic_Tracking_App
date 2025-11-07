# Scripts du Backend

Ce document décrit tous les scripts disponibles dans le dossier `backend/`.

## Scripts de démarrage

### `start_backend.bat`
Script batch pour démarrer le backend manuellement (avec fenêtre visible).
- **Usage** : Double-cliquer ou exécuter dans un terminal
- **Fonction** : Lance le backend Flask avec l'environnement virtuel Python 3.13

### `start_backend.ps1`
Script PowerShell pour démarrer le backend.
- **Usage** : `.\start_backend.ps1`
- **Fonction** : Vérifie l'environnement virtuel et lance Flask

### `start_backend_background.bat`
Script pour le démarrage automatique au démarrage de Windows.
- **Usage** : Utilisé par la tâche planifiée Windows
- **Fonction** : Lance le backend en arrière-plan avec logs redirigés
- **Logs** : `backend.log` et `backend_error.log`

### `start_backend_silent.vbs`
Script VBS pour lancer le backend sans fenêtre visible.
- **Usage** : Double-cliquer ou utiliser pour le démarrage automatique
- **Fonction** : Lance `start_backend.bat` en arrière-plan

### `start_monitoring.bat`
Script de surveillance qui redémarre automatiquement le backend s'il s'arrête.
- **Usage** : `.\start_monitoring.bat`
- **Fonction** : Vérifie toutes les 60 secondes si le backend est en cours d'exécution

## Scripts de configuration

### `create_scheduled_task.ps1`
Script pour créer la tâche planifiée Windows pour le démarrage automatique.
- **Usage** : Exécuter en tant qu'administrateur
- **Fonction** : Crée la tâche `TrafficTrackingBackend` dans le Planificateur de tâches
- **Privilèges requis** : Administrateur

## Scripts de base de données

### `init_database.py`
Initialise la base de données PostgreSQL (crée la base si elle n'existe pas).
- **Usage** : `python init_database.py`
- **Fonction** : Crée la base de données `Traffic_Tracking` avec encodage UTF8
- **Attention** : Supprime la base existante si elle existe déjà

### `create_table.py`
Crée la table `gps_points` dans la base de données.
- **Usage** : `python create_table.py`
- **Fonction** : Crée la table en utilisant les variables d'environnement du fichier `.env`
- **Note** : Demande confirmation si la table existe déjà

### `create_table_interactive.py`
Version interactive de `create_table.py` qui demande les credentials.
- **Usage** : `python create_table_interactive.py`
- **Fonction** : Crée la table en demandant interactivement les informations de connexion
- **Avantage** : Ne nécessite pas de fichier `.env`

## Scripts de test

### `test_connection.py`
Teste la connexion au backend Flask et vérifie les endpoints.
- **Usage** : `python test_connection.py`
- **Fonction** : 
  - Teste le endpoint `/health`
  - Teste l'envoi de données GPS (`/send_gps`)
  - Teste la récupération de données (`/get_points`)
- **Prérequis** : Le backend doit être lancé

## Scripts de maintenance

### `backup.bat`
Sauvegarde la base de données PostgreSQL.
- **Usage** : `.\backup.bat`
- **Fonction** : Crée une sauvegarde de la base `Traffic_Tracking` dans le dossier `backups/`
- **Format** : Fichier SQL avec date dans le nom

## Recommandations d'utilisation

### Pour le développement
1. Utiliser `start_backend.bat` ou `start_backend.ps1` pour voir les logs en temps réel

### Pour la production
1. Configurer le démarrage automatique avec `create_scheduled_task.ps1`
2. Utiliser `start_backend_background.bat` pour les logs en fichiers
3. Optionnel : Utiliser `start_monitoring.bat` pour redémarrage automatique

### Pour la première installation
1. Créer le fichier `.env` avec les paramètres de connexion
2. Exécuter `python init_database.py` pour créer la base
3. Exécuter `python create_table.py` pour créer la table
4. Tester avec `python test_connection.py`

## Structure recommandée des fichiers

```
backend/
├── app.py                          # Application Flask principale
├── requirements.txt                # Dépendances Python
├── .env                           # Variables d'environnement (non versionné)
├── README.md                      # Documentation principale
├── SCRIPTS.md                     # Ce fichier
├── CONFIGURER_DEMARRAGE_AUTO.md   # Guide de démarrage automatique
├── INIT_DATABASE.md               # Guide d'initialisation de la base
├── start_backend.bat             # Démarrage manuel
├── start_backend.ps1              # Démarrage PowerShell
├── start_backend_background.bat   # Démarrage automatique
├── start_backend_silent.vbs       # Démarrage silencieux
├── start_monitoring.bat           # Surveillance
├── create_scheduled_task.ps1      # Configuration tâche planifiée
├── init_database.py               # Initialisation DB
├── create_table.py                # Création table (avec .env)
├── create_table_interactive.py    # Création table (interactif)
├── test_connection.py             # Tests
├── backup.bat                     # Sauvegarde
└── venv/                          # Environnement virtuel Python
```

