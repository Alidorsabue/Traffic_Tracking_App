# Configuration de l'URL du Backend pour les Builds de Production

## 📋 Problème résolu

L'application utilisait `10.0.2.2:5000` qui ne fonctionne que dans l'émulateur Android. Pour un APK déployé sur un appareil physique, il faut utiliser l'IP réelle du serveur backend.

## ✅ Solution

Les scripts de build ont été mis à jour pour :
1. **Détecter automatiquement l'IP locale** du PC lors du build APK
2. **Permettre de spécifier une URL personnalisée** pour le serveur de production
3. **Configurer l'URL au build time** via `--dart-define=API_BASE_URL`

## 🚀 Utilisation

### Pour générer un APK pour appareil physique

```powershell
cd mobile_app
.\build_android_apk.bat
```

Le script va :
1. Détecter automatiquement l'IP locale de votre PC (ex: `192.168.0.121`)
2. Vous proposer d'utiliser cette IP ou d'en entrer une autre
3. Générer l'APK avec cette URL configurée

**Exemple d'interaction :**
```
[INFO] IP detectee: 192.168.0.121
[INFO] URL du backend: http://192.168.0.121:5000

Appuyez sur Entree pour utiliser cette IP, ou entrez une autre IP/adresse (ex: 192.168.1.100 ou https://votre-serveur.com):
```

- **Appuyez sur Entrée** → Utilise l'IP détectée automatiquement
- **Entrez une IP** (ex: `192.168.1.100`) → Utilise cette IP
- **Entrez une URL complète** (ex: `https://votre-serveur.com`) → Utilise cette URL

### Pour générer un AAB pour Google Play Store

```powershell
cd mobile_app
.\build_android_aab.bat
```

Le script va vous demander l'URL de votre serveur de production.

**Exemples d'URL acceptées :**
- `https://votre-serveur.com` (le port 5000 sera ajouté automatiquement)
- `https://api.votre-domaine.com:5000` (avec port spécifié)
- `http://192.168.1.100:5000` (IP locale)

## 🔧 Configuration manuelle

Si vous préférez configurer l'URL manuellement lors du build, vous pouvez utiliser :

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://VOTRE_IP:5000
```

ou

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://votre-serveur.com:5000
```

## 📱 Différences selon l'environnement

| Environnement | URL à utiliser | Exemple |
|--------------|----------------|---------|
| **Émulateur Android** | `10.0.2.2` | `http://10.0.2.2:5000` |
| **Appareil physique (même réseau)** | IP locale du PC | `http://192.168.0.121:5000` |
| **Production (serveur distant)** | URL du serveur | `https://api.votre-domaine.com:5000` |

## ⚠️ Points importants

1. **Backend accessible** : Assurez-vous que le backend Flask est accessible depuis l'appareil :
   - Sur le même réseau Wi-Fi pour une IP locale
   - Accessible publiquement pour un serveur de production

2. **Pare-feu** : Vérifiez que le port 5000 est ouvert dans le pare-feu Windows

3. **URL dans l'APK** : L'URL est compilée dans l'APK au moment du build. Pour changer l'URL, il faut régénérer l'APK.

4. **HTTPS en production** : Pour un serveur de production, utilisez HTTPS pour la sécurité

## 🧪 Test de l'URL

Avant de générer l'APK, testez que le backend est accessible :

**Depuis un navigateur sur votre PC :**
```
http://192.168.0.121:5000/health
```

**Depuis un appareil Android sur le même réseau :**
Ouvrez Chrome et allez à :
```
http://192.168.0.121:5000/health
```

Si vous obtenez une réponse JSON, le backend est accessible.

## 🔍 Vérifier l'URL configurée dans l'APK

L'URL utilisée par l'application est affichée dans les messages d'erreur si une connexion échoue. Vous verrez :
```
Network error (URL: http://...): ...
```

## 📝 Notes

- L'URL est définie au **build time**, pas au runtime
- Pour changer l'URL, il faut **régénérer l'APK**
- Le script détecte automatiquement l'IP, mais vous pouvez toujours la modifier
- Pour Google Play Store, utilisez l'URL de votre serveur de production (HTTPS recommandé)


