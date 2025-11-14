#!/bin/bash

# Script pour lancer l'app avec correction automatique du bug Flutter

echo "🚀 Lancement de CropGuardian..."
echo ""

# Étape 1: Vérifier le téléphone
echo "📱 Vérification du téléphone..."
DEVICE=$(adb devices | grep "device$" | awk '{print $1}')

if [ -z "$DEVICE" ]; then
    echo "❌ Aucun téléphone détecté!"
    echo "   Branchez votre téléphone et autorisez le débogage USB"
    echo "   Puis relancez ce script"
    exit 1
fi

echo "✅ Téléphone détecté: $DEVICE"
echo ""

# Étape 2: Nettoyer et préparer
echo "🧹 Nettoyage des fichiers temporaires..."
flutter clean > /dev/null 2>&1
rm -rf android/app/build android/.gradle android/build > /dev/null 2>&1
echo "✅ Nettoyage terminé"
echo ""

# Étape 3: Récupérer les dépendances
echo "📦 Téléchargement des dépendances..."
flutter pub get > /dev/null 2>&1
echo "✅ Dépendances installées"
echo ""

# Étape 4: Lancer la compilation en arrière-plan
echo "🔨 Compilation de l'application..."
echo "   (Cela peut prendre 2-3 minutes la première fois)"
echo ""

# Lancer flutter run en arrière-plan et capturer la sortie
flutter run -d $DEVICE 2>&1 | tee /tmp/flutter_build.log &
FLUTTER_PID=$!

# Attendre que le fichier GeneratedPluginRegistrant.java soit créé
echo "⏳ Attente de la génération des fichiers..."
sleep 30

# Corriger le fichier s'il existe
PLUGIN_FILE="android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
if [ -f "$PLUGIN_FILE" ]; then
    echo "🔧 Correction du bug Flutter..."
    
    # Vérifier si l'import Log manque
    if ! grep -q "import android.util.Log;" "$PLUGIN_FILE"; then
        # Ajouter l'import après le package
        sed -i '/^package io.flutter.plugins;/a import android.util.Log;' "$PLUGIN_FILE"
        echo "✅ Fichier corrigé!"
        
        # Tuer le processus flutter et relancer
        echo "🔄 Relancement de la compilation..."
        kill $FLUTTER_PID 2>/dev/null
        sleep 2
        
        # Relancer
        flutter run -d $DEVICE
    else
        echo "✅ Fichier déjà correct, compilation en cours..."
        # Attendre que flutter se termine
        wait $FLUTTER_PID
    fi
else
    echo "⚠️ Fichier non trouvé, attente de la compilation..."
    wait $FLUTTER_PID
fi
