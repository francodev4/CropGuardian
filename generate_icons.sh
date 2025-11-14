#!/bin/bash

# Script de génération d'icônes pour Android
# Usage: ./generate_icons.sh

echo "🎨 Génération des icônes Android..."

# Chemin vers votre logo
LOGO="assets/icons/app_logo.png"
OUTPUT_DIR="android/app/src/main/res"

# Vérifier que le logo existe
if [ ! -f "$LOGO" ]; then
    echo "❌ Erreur: Le fichier $LOGO n'existe pas!"
    exit 1
fi

# Vérifier qu'ImageMagick est installé
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick n'est pas installé!"
    echo "📦 Installation: sudo apt-get install imagemagick"
    exit 1
fi

# Créer les dossiers si nécessaire
echo "📁 Création des dossiers..."
mkdir -p "$OUTPUT_DIR/mipmap-mdpi"
mkdir -p "$OUTPUT_DIR/mipmap-hdpi"
mkdir -p "$OUTPUT_DIR/mipmap-xhdpi"
mkdir -p "$OUTPUT_DIR/mipmap-xxhdpi"
mkdir -p "$OUTPUT_DIR/mipmap-xxxhdpi"

# Générer les icônes aux différentes tailles
echo "🖼️  Génération des icônes..."
convert "$LOGO" -resize 48x48 "$OUTPUT_DIR/mipmap-mdpi/ic_launcher.png"
echo "  ✓ mdpi (48x48)"

convert "$LOGO" -resize 72x72 "$OUTPUT_DIR/mipmap-hdpi/ic_launcher.png"
echo "  ✓ hdpi (72x72)"

convert "$LOGO" -resize 96x96 "$OUTPUT_DIR/mipmap-xhdpi/ic_launcher.png"
echo "  ✓ xhdpi (96x96)"

convert "$LOGO" -resize 144x144 "$OUTPUT_DIR/mipmap-xxhdpi/ic_launcher.png"
echo "  ✓ xxhdpi (144x144)"

convert "$LOGO" -resize 192x192 "$OUTPUT_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo "  ✓ xxxhdpi (192x192)"

echo ""
echo "✅ Icônes générées avec succès!"
echo ""
echo "📋 Fichiers créés:"
ls -lh "$OUTPUT_DIR"/mipmap-*/ic_launcher.png

echo ""
echo "🚀 Prochaines étapes:"
echo "  1. flutter clean"
echo "  2. flutter run -d YHTG7HKBRSV4EMEI"
