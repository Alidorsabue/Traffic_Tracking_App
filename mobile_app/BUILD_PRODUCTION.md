# Guide de Build de Production

Ce guide explique comment générer les builds de production pour Android et iOS.

## 📱 Android

### Option 1 : APK (Installation directe)

Pour générer un APK que vous pouvez installer directement sur un appareil Android :

```powershell
cd mobile_app
.\build_android_apk.ps1
```

Le fichier APK sera généré dans le dossier `builds/` avec un nom incluant la date et l'heure.

**Installation :**
```powershell
adb install builds\traffic_tracking_app_v[timestamp].apk
```

### Option 2 : AAB (Google Play Store)

Pour générer un Android App Bundle pour la publication sur Google Play Store :

```powershell
cd mobile_app
.\build_android_aab.ps1
```

Le fichier AAB sera généré dans le dossier `builds/`.

**⚠️ IMPORTANT pour Google Play Store :**

1. **Configurer la signature de l'application :**
   - Créer un fichier keystore pour signer l'application
   - Configurer la signature dans `android/app/build.gradle.kts`

2. **Créer un keystore :**
   ```powershell
   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. **Mettre à jour `android/app/build.gradle.kts` :**
   ```kotlin
   android {
       signingConfigs {
           release {
               keyAlias 'upload'
               keyPassword 'VOTRE_MOT_DE_PASSE'
               storeFile file('upload-keystore.jks')
               storePassword 'VOTRE_MOT_DE_PASSE'
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

4. **Créer un fichier `android/key.properties` (et l'ajouter au .gitignore) :**
   ```properties
   storePassword=VOTRE_MOT_DE_PASSE
   keyPassword=VOTRE_MOT_DE_PASSE
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

## 🍎 iOS

**⚠️ IMPORTANT :** La génération de builds iOS nécessite :
- Un Mac avec macOS
- Xcode installé
- Un compte développeur Apple (pour la publication sur l'App Store)

### Build iOS (nécessite Mac)

1. **Ouvrir le projet dans Xcode :**
   ```bash
   cd mobile_app/ios
   open Runner.xcworkspace
   ```

2. **Configurer le Bundle Identifier :**
   - Dans Xcode, sélectionner le projet "Runner"
   - Aller dans l'onglet "Signing & Capabilities"
   - Configurer votre Team et Bundle Identifier unique

3. **Configurer la clé API Google Maps pour iOS :**
   - Ajouter votre clé API dans `ios/Runner/AppDelegate.swift` ou `Info.plist`

4. **Générer le build IPA :**
   
   **Option A : Via Xcode**
   - Menu : Product > Archive
   - Une fois l'archive créée, cliquer sur "Distribute App"
   - Choisir la méthode de distribution (App Store, Ad Hoc, Enterprise, Development)

   **Option B : Via ligne de commande (Flutter) :**
   ```bash
   cd mobile_app
   flutter build ipa --release
   ```
   
   Le fichier IPA sera dans `build/ios/ipa/`

5. **Pour tester sur un appareil iOS :**
   ```bash
   flutter build ios --release
   ```
   
   Puis ouvrir le projet dans Xcode et installer via Xcode.

## 📋 Checklist avant le build de production

### Android
- [ ] Vérifier que l'Application ID est correct (`com.example.traffic_tracking_app`)
- [ ] **Configurer l'URL du backend** (voir `CONFIGURATION_URL_BACKEND.md`)
- [ ] Configurer la clé API Google Maps dans `AndroidManifest.xml`
- [ ] Configurer la signature pour les builds de release
- [ ] Tester l'application en mode release localement
- [ ] Vérifier les permissions dans `AndroidManifest.xml`
- [ ] Mettre à jour le nom de l'application et la version dans `pubspec.yaml`
- [ ] Vérifier que le backend est accessible depuis l'appareil cible

### iOS
- [ ] Vérifier le Bundle Identifier
- [ ] Configurer la clé API Google Maps pour iOS
- [ ] Configurer les permissions de localisation dans `Info.plist`
- [ ] Tester sur un appareil iOS réel
- [ ] Vérifier les certificats de signature dans Xcode
- [ ] Mettre à jour le nom de l'application et la version

## 🔧 Configuration de la version

Pour mettre à jour la version de l'application, modifiez `pubspec.yaml` :

```yaml
version: 1.0.0+1
# Format: version_name+build_number
# Exemple: 1.0.0+1 signifie version 1.0.0, build 1
```

Pour Android, cela mettra à jour :
- `versionName` dans `build.gradle.kts`
- `versionCode` dans `build.gradle.kts`

Pour iOS, cela mettra à jour :
- `CFBundleShortVersionString` dans `Info.plist`
- `CFBundleVersion` dans `Info.plist`

## 📝 Notes importantes

1. **Keystore Android :** Conservez votre fichier keystore en sécurité ! Si vous le perdez, vous ne pourrez plus mettre à jour votre application sur Google Play.

2. **Certificats iOS :** Les certificats iOS expirent après un certain temps. Vérifiez régulièrement leur validité dans le portail développeur Apple.

3. **Backend API :** Assurez-vous que l'URL du backend dans l'application de production pointe vers votre serveur de production, pas vers `localhost` ou une IP locale.

4. **Google Maps API :** Vérifiez que vos restrictions de clé API permettent les requêtes depuis votre application de production.

5. **Tests :** Toujours tester l'application en mode release avant de la publier.

## 🚀 Publication

### Google Play Store
1. Créer un compte développeur Google Play (frais unique de $25)
2. Créer une nouvelle application dans Google Play Console
3. Uploader le fichier AAB
4. Remplir les informations de l'application
5. Soumettre pour révision

### Apple App Store
1. Créer un compte développeur Apple (frais annuels de $99)
2. Créer une nouvelle application dans App Store Connect
3. Uploader le fichier IPA via Xcode ou Transporter
4. Remplir les informations de l'application
5. Soumettre pour révision

