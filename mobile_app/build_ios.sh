#!/bin/bash
# Script bash pour generer le build iOS (necessite Mac)
# Usage: ./build_ios.sh
#
# IMPORTANT: Ce script necessite:
# - macOS avec Xcode installe
# - Un compte developpeur Apple configure dans Xcode
# - Flutter installe sur macOS

set -e

echo "============================================================"
echo "Build iOS IPA - Production"
echo "============================================================"
echo ""

# Verifier que nous sommes sur macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "[ERREUR] Ce script necessite macOS et Xcode"
    exit 1
fi

# Naviguer dans le dossier mobile_app
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Creer le dossier builds s'il n'existe pas
BUILDS_DIR="$SCRIPT_DIR/builds"
mkdir -p "$BUILDS_DIR"

echo "[ETAPE 1/5] Nettoyage du build precedent..."
flutter clean
echo "[OK] Nettoyage termine"
echo ""

echo "[ETAPE 2/5] Installation des dependances..."
flutter pub get
echo "[OK] Dependances installees"
echo ""

echo "[ETAPE 3/5] Verification de la configuration..."
echo "[INFO] Bundle Identifier: com.example.trafficTrackingApp"
echo "[WARNING] IMPORTANT: Assurez-vous que la signature est configuree dans Xcode!" -ForegroundColor Red
echo "[WARNING] Ouvrez ios/Runner.xcworkspace dans Xcode et configurez votre Team" -ForegroundColor Red
echo ""

# Demander confirmation
read -p "Continuer avec le build iOS? (O/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Build annule."
    exit 0
fi

echo "[ETAPE 4/5] Generation du build IPA..."
echo "[INFO] Cela peut prendre plusieurs minutes..."

# Generer le build IPA
flutter build ipa --release

if [ $? -ne 0 ]; then
    echo "[ERREUR] Erreur lors de la generation du build IPA"
    exit 1
fi

echo "[OK] Build IPA genere avec succes!"
echo ""

echo "[ETAPE 5/5] Localisation du fichier IPA..."

# Trouver le fichier IPA genere
IPA_PATH="$SCRIPT_DIR/build/ios/ipa/traffic_tracking_app.ipa"

if [ -f "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    
    echo "[OK] IPA trouve: $IPA_PATH"
    echo "[INFO] Taille: $IPA_SIZE"
    
    # Copier vers le dossier builds avec un nom descriptif
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    IPA_NAME="traffic_tracking_app_v$TIMESTAMP.ipa"
    DESTINATION_PATH="$BUILDS_DIR/$IPA_NAME"
    cp "$IPA_PATH" "$DESTINATION_PATH"
    echo "[INFO] IPA copie vers: $DESTINATION_PATH"
    echo ""
    echo "============================================================"
    echo "Build termine avec succes!"
    echo "============================================================"
    echo ""
    echo "Fichier IPA: $DESTINATION_PATH"
    echo ""
    echo "Vous pouvez maintenant uploader ce fichier sur App Store Connect."
    echo "URL: https://appstoreconnect.apple.com"
else
    echo "[ERREUR] Fichier IPA non trouve: $IPA_PATH"
    exit 1
fi

