#!/bin/bash

# Script pour corriger le fichier GeneratedPluginRegistrant.java
# Ce fichier est généré automatiquement par Flutter mais manque l'import Log

PLUGIN_FILE="android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"

if [ -f "$PLUGIN_FILE" ]; then
    echo "🔧 Correction du fichier GeneratedPluginRegistrant.java..."
    
    # Ajouter l'import android.util.Log après le package
    sed -i '/^package io.flutter.plugins;/a import android.util.Log;' "$PLUGIN_FILE"
    
    echo "✅ Fichier corrigé!"
else
    echo "⚠️ Fichier non trouvé: $PLUGIN_FILE"
    echo "Lancez d'abord: flutter build apk ou flutter run"
fi
