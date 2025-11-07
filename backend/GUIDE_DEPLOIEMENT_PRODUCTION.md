# Guide de déploiement en production

## 🎯 Objectif

Permettre à l'application mobile de fonctionner sur **tous les téléphones**, peu importe le réseau.

## 📋 Prérequis

1. **Serveur accessible publiquement** (VPS, Cloud, etc.)
2. **Nom de domaine** (optionnel mais recommandé)
3. **Certificat SSL** (HTTPS - obligatoire pour la sécurité)

## 🚀 Étapes de déploiement

### 1. Déployer le backend sur un serveur

#### Option A : Serveur VPS (DigitalOcean, AWS, OVH, etc.)

1. **Installer Python et PostgreSQL** sur le serveur
2. **Copier le code du backend** sur le serveur
3. **Configurer les variables d'environnement** :
   ```bash
   # .env.production
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=Traffic_Tracking
   DB_USER=postgres
   DB_PASSWORD=votre_mot_de_passe_securise
   
   FLASK_PORT=5000
   FLASK_DEBUG=false
   CORS_ORIGINS=https://votre-domaine.com,https://www.votre-domaine.com
   ```

4. **Installer les dépendances** :
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

5. **Configurer un service systemd** pour démarrer automatiquement :
   ```ini
   # /etc/systemd/system/traffic-tracking.service
   [Unit]
   Description=Traffic Tracking Backend
   After=network.target

   [Service]
   Type=simple
   User=www-data
   WorkingDirectory=/path/to/backend
   Environment="PATH=/path/to/backend/.venv/bin"
   ExecStart=/path/to/backend/.venv/bin/waitress-serve --host=0.0.0.0 --port=5000 wsgi:application
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

6. **Démarrer le service** :
   ```bash
   sudo systemctl enable traffic-tracking
   sudo systemctl start traffic-tracking
   ```

#### Option B : Plateforme Cloud (Heroku, Railway, Render, etc.)

1. **Créer un compte** sur la plateforme
2. **Connecter votre repository Git**
3. **Configurer les variables d'environnement** dans le dashboard
4. **Déployer** (généralement automatique)

### 2. Configurer HTTPS (obligatoire)

#### Avec Nginx (recommandé)

1. **Installer Nginx** :
   ```bash
   sudo apt-get update
   sudo apt-get install nginx certbot python3-certbot-nginx
   ```

2. **Configurer Nginx** :
   ```nginx
   # /etc/nginx/sites-available/traffic-tracking
   server {
       listen 80;
       server_name api.votre-domaine.com;

       location / {
           proxy_pass http://127.0.0.1:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

3. **Activer le site** :
   ```bash
   sudo ln -s /etc/nginx/sites-available/traffic-tracking /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Obtenir un certificat SSL** :
   ```bash
   sudo certbot --nginx -d api.votre-domaine.com
   ```

### 3. Mettre à jour l'application mobile

#### Générer un APK avec l'URL de production

```powershell
cd mobile_app

# Option 1 : Utiliser le script automatique
.\build_android_apk.bat
# Quand demandé, entrez : https://api.votre-domaine.com

# Option 2 : Commande manuelle
flutter build apk --release --dart-define=API_BASE_URL=https://api.votre-domaine.com:5000
```

#### Générer un AAB pour Google Play Store

```powershell
cd mobile_app

# Option 1 : Utiliser le script automatique
.\build_android_aab.bat
# Quand demandé, entrez : https://api.votre-domaine.com

# Option 2 : Commande manuelle
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.votre-domaine.com:5000
```

## ✅ Vérifications

### 1. Tester le backend depuis n'importe où

```bash
curl https://api.votre-domaine.com/health
```

Vous devriez recevoir une réponse JSON.

### 2. Tester depuis un téléphone

Sur votre téléphone, ouvrez Chrome et allez sur :
```
https://api.votre-domaine.com/health
```

### 3. Tester l'application mobile

Installez l'APK généré sur un téléphone (même sur un autre réseau Wi-Fi ou en 4G) et testez.

## 🔒 Sécurité

### Recommandations importantes

1. **HTTPS obligatoire** : Ne jamais utiliser HTTP en production
2. **CORS configuré** : Limiter les origines autorisées
3. **Mot de passe fort** : Pour PostgreSQL et les comptes serveur
4. **Firewall** : Ne laisser que les ports nécessaires ouverts
5. **Mises à jour** : Maintenir le système et les dépendances à jour

### Configuration CORS recommandée

```python
# .env.production
CORS_ORIGINS=https://votre-domaine.com,https://www.votre-domaine.com
```

## 📱 Différences : Local vs Production

| Aspect | Local (actuel) | Production (recommandé) |
|--------|----------------|------------------------|
| **URL** | `http://192.168.0.121:5000` | `https://api.votre-domaine.com` |
| **Réseau** | Même Wi-Fi requis | Fonctionne partout (4G, Wi-Fi, etc.) |
| **Sécurité** | HTTP (non sécurisé) | HTTPS (sécurisé) |
| **Accessibilité** | Seulement réseau local | Accessible publiquement |
| **APK** | Un APK par réseau | Un seul APK pour tous |

## 🛠️ Alternative : Configuration dynamique

Si vous ne pouvez pas déployer sur un serveur public, vous pouvez modifier l'application pour permettre à l'utilisateur de configurer l'URL du backend dans l'app. Cela nécessite des modifications du code Flutter.

## 📝 Résumé

Pour que l'application fonctionne sur **tous les téléphones** :

1. ✅ **Déployer le backend** sur un serveur accessible publiquement
2. ✅ **Configurer HTTPS** (certificat SSL)
3. ✅ **Générer l'APK** avec l'URL de production
4. ✅ **Distribuer l'APK** (Google Play Store, APK direct, etc.)

Une fois ces étapes complétées, l'application fonctionnera sur n'importe quel téléphone, peu importe le réseau.


