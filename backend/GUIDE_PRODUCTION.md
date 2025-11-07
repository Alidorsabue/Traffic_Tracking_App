# 🚀 Guide de Déploiement en Mode Production

Ce guide explique comment déployer le backend Flask en mode production avec un serveur WSGI (Waitress).

## ⚠️ Différences entre Développement et Production

| Aspect | Développement | Production |
|--------|---------------|------------|
| **Serveur** | Flask development server | Waitress (WSGI) |
| **Debug** | Activé (`FLASK_DEBUG=true`) | Désactivé (`FLASK_DEBUG=false`) |
| **Performance** | Basique, single-threaded | Multi-threaded, optimisé |
| **Sécurité** | Moins sécurisé | Plus sécurisé |
| **Logs** | Console | Fichiers de logs |
| **Recommandé pour** | Développement local | Déploiement réel |

## 📋 Prérequis

1. **Python 3.8+** installé
2. **PostgreSQL** configuré et accessible
3. **Waitress** installé (sera installé automatiquement)
4. **Pare-feu** configuré pour le port choisi

## 🔧 Installation

### 1. Installer Waitress

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
pip install waitress
```

Ou simplement réinstaller toutes les dépendances :
```powershell
pip install -r requirements.txt
```

### 2. Créer le fichier de configuration production

```powershell
cd backend
Copy-Item .env.production.example .env.production
```

### 3. Modifier `.env.production`

Ouvrez `.env.production` et configurez :

```env
# IMPORTANT: Désactiver le mode debug
FLASK_DEBUG=false
FLASK_ENV=production

# Configuration de la base de données (production)
DB_HOST=votre-serveur-db
DB_PORT=5433
DB_NAME=Traffic_Tracking
DB_USER=postgres
DB_PASSWORD=VOTRE_MOT_DE_PASSE_FORT

# Configuration Waitress
WAITRESS_HOST=0.0.0.0
WAITRESS_PORT=5000
WAITRESS_THREADS=4
WAITRESS_CHANNEL_TIMEOUT=120

# Générer une clé secrète
# python -c "import secrets; print(secrets.token_hex(32))"
SECRET_KEY=VOTRE_CLE_SECRETE_GENEREE
```

### 4. Générer une clé secrète

```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```

Copiez le résultat dans `SECRET_KEY` dans `.env.production`.

## 🚀 Démarrage en Mode Production

### Option 1 : Script PowerShell (Recommandé)

```powershell
cd backend
.\start_backend_production.ps1
```

### Option 2 : Commande manuelle

```powershell
cd backend
.\.venv\Scripts\Activate.ps1

# Charger les variables d'environnement
Get-Content .env.production | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($name -and $value) {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

# Lancer Waitress
waitress-serve --host=0.0.0.0 --port=5000 --threads=4 wsgi:app
```

## ⚙️ Configuration Avancée

### Optimisation des performances

**Threads :**
- Défaut : 4 threads
- Pour un serveur avec peu de charge : 2-4 threads
- Pour un serveur avec beaucoup de charge : 8-16 threads

**Timeout :**
- Défaut : 120 secondes
- Augmentez si vous avez des requêtes longues

**Exemple configuration serveur puissant :**
```env
WAITRESS_THREADS=8
WAITRESS_CHANNEL_TIMEOUT=300
```

### Configuration du domaine et HTTPS

Pour utiliser HTTPS, vous devez utiliser un reverse proxy (Nginx, Apache) ou un service comme Cloudflare.

**Exemple avec Nginx (Linux) :**
```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔒 Sécurité en Production

### 1. Variables d'environnement sensibles

⚠️ **NE JAMAIS** commiter le fichier `.env.production` dans Git !

Ajoutez à `.gitignore` :
```
.env.production
.env.local
```

### 2. Mots de passe forts

- Utilisez des mots de passe forts pour PostgreSQL
- Changez la clé secrète Flask régulièrement
- Ne réutilisez pas les mots de passe de développement

### 3. CORS (Cross-Origin Resource Sharing)

Configurez les origines autorisées dans `.env.production` :

```env
# Autoriser uniquement votre domaine
CORS_ORIGINS=https://votre-domaine.com,https://app.votre-domaine.com
```

Puis modifiez `app.py` pour utiliser cette configuration :
```python
allowed_origins = os.getenv("CORS_ORIGINS", "*").split(",")
CORS(app, origins=allowed_origins)
```

### 4. Pare-feu

- Configurez le pare-feu pour autoriser uniquement les ports nécessaires
- Utilisez le script `configure_firewall.ps1`

### 5. HTTPS

En production, utilisez **toujours HTTPS** :
- Utilisez un certificat SSL (Let's Encrypt, Cloudflare, etc.)
- Configurez un reverse proxy (Nginx, Apache, IIS)

## 📊 Monitoring et Logs

### Logs

Les logs sont écrits dans le dossier `logs/` (créé automatiquement).

Pour voir les logs en temps réel :
```powershell
Get-Content logs/app.log -Wait
```

### Vérification de santé

Vérifiez que le serveur fonctionne :
```powershell
Invoke-WebRequest -Uri http://localhost:5000/health -UseBasicParsing
```

### Monitoring des performances

Utilisez des outils comme :
- **Task Manager** : Surveiller l'utilisation CPU/RAM
- **Performance Monitor** : Surveiller les métriques système
- **Application Insights** : Pour un monitoring avancé

## 🔄 Démarrage Automatique

### Option 1 : Tâche planifiée Windows

```powershell
cd backend
.\create_scheduled_task.ps1
```

Modifiez le script pour utiliser `start_backend_production.ps1` au lieu de `start_backend.ps1`.

### Option 2 : Service Windows (avancé)

Créez un service Windows avec NSSM (Non-Sucking Service Manager) :

1. Téléchargez NSSM : https://nssm.cc/download
2. Installez le service :
```powershell
nssm install TrafficTrackingBackend "C:\path\to\python.exe" "C:\path\to\backend\wsgi.py"
nssm set TrafficTrackingBackend AppDirectory "C:\path\to\backend"
nssm start TrafficTrackingBackend
```

## 🐛 Dépannage

### Le serveur ne démarre pas

1. Vérifiez que Waitress est installé :
   ```powershell
   pip list | findstr waitress
   ```

2. Vérifiez les logs d'erreur

3. Testez la configuration :
   ```powershell
   python -c "from wsgi import app; print('OK')"
   ```

### Erreurs de connexion à la base de données

1. Vérifiez que PostgreSQL est accessible
2. Vérifiez les credentials dans `.env.production`
3. Testez la connexion :
   ```powershell
   python init_database.py
   ```

### Performance lente

1. Augmentez le nombre de threads :
   ```env
   WAITRESS_THREADS=8
   ```

2. Vérifiez les ressources système (CPU, RAM)

3. Optimisez les requêtes SQL dans `app.py`

## 📝 Checklist de Déploiement

- [ ] Waitress installé
- [ ] Fichier `.env.production` créé et configuré
- [ ] `FLASK_DEBUG=false` dans `.env.production`
- [ ] Clé secrète générée et configurée
- [ ] Mots de passe forts pour la base de données
- [ ] Pare-feu configuré
- [ ] CORS configuré (si nécessaire)
- [ ] HTTPS configuré (si accessible depuis Internet)
- [ ] Logs configurés
- [ ] Démarrage automatique configuré (optionnel)
- [ ] Tests de charge effectués
- [ ] Backup de la base de données configuré

## 🔗 Ressources

- [Documentation Waitress](https://docs.pylonsproject.org/projects/waitress/en/latest/)
- [Flask Production Best Practices](https://flask.palletsprojects.com/en/latest/deploying/)
- [PostgreSQL Security](https://www.postgresql.org/docs/current/security.html)

---

**Dernière mise à jour :** Novembre 2025

