# 🌾 CropGuardian - Application de Protection des Cultures

Application mobile Flutter pour l'identification et la gestion des ravageurs agricoles avec intelligence artificielle.

---

## 📱 **FONCTIONNALITÉS PRINCIPALES**

### 🔍 **1. Identification d'Insectes**

#### **Scan par Image (Caméra/Galerie)**
- **Technologie**: TensorFlow Lite + Gemini Vision AI
- **Processus en cascade**:
  1. **TFLite Local** (On-device) - Rapide et privé
  2. **Gemini Vision** (Cloud) - Haute précision
  3. **HuggingFace** (Cloud) - Modèles spécialisés
  4. **Model Zoo** (Fallback) - Dernière option
  
- **Résultats fournis**:
  - Nom de l'insecte identifié
  - Niveau de confiance (%)
  - Sévérité de l'infestation (Faible/Moyen/Élevé)
  - Recommandations de traitement
  - Source de détection (TFLite/Gemini/etc.)

#### **Recherche par Description**
- **Technologie**: Gemini AI (Google)
- **Fonctionnement**:
  1. Utilisateur décrit l'insecte en langage naturel
  2. Gemini AI analyse la description
  3. Identification de l'insecte le plus probable
  4. Recherche dans la base de données locale
  5. Affichage des résultats correspondants

**Exemple**: "Petit insecte vert sur mes tomates" → Puceron vert

---

### 📚 **2. Collection d'Insectes**

- **Base de données locale**: 25+ espèces d'insectes ravageurs
- **Informations détaillées**:
  - Nom commun et scientifique
  - Photos haute résolution
  - Description complète
  - Cultures affectées
  - Symptômes d'infestation
  - Méthodes de traitement (bio et chimique)
  - Cycle de vie
  - Prévention

- **Fonctionnalités**:
  - Recherche par nom
  - Filtrage par catégorie
  - Favoris
  - Partage d'informations

---

### 🗺️ **3. Gestion des Champs**

#### **Création et Suivi**
- Ajouter des champs avec:
  - Nom du champ
  - Type de culture
  - Surface (hectares)
  - Localisation GPS
  - Photo du champ

#### **Surveillance des Infestations**
- **Signalement d'infestation**:
  - Depuis la collection d'insectes
  - Sélection du champ concerné
  - Niveau de sévérité
  - Zone affectée (%)
  - Notes personnalisées
  - Photo de l'infestation
  - Géolocalisation automatique

- **Statut des champs**:
  - 🟢 Sain (aucune infestation)
  - 🟡 Surveillance (infestations mineures)
  - 🔴 Alerte (infestations graves)

#### **Historique**
- Toutes les détections passées
- Évolution des infestations
- Traitements appliqués
- Statistiques par champ

---

### 📊 **4. Tableau de Bord**

#### **Vue d'ensemble**
- Nombre total de champs
- Infestations actives
- Détections récentes
- Alertes urgentes

#### **Statistiques**
- Graphiques d'évolution
- Insectes les plus fréquents
- Efficacité des traitements
- Tendances saisonnières

#### **Cartes**
- Visualisation géographique des champs
- Zones à risque
- Propagation des infestations

---

### 🌤️ **5. Météo Agricole**

- **Prévisions locales**:
  - Température
  - Humidité
  - Précipitations
  - Vent
  - Pression atmosphérique

- **Alertes météo**:
  - Conditions favorables aux ravageurs
  - Périodes de traitement optimales
  - Risques climatiques

- **Intégration**: OpenWeatherMap API

---

### 📜 **6. Historique des Détections**

- **Toutes les analyses d'images**
- **Filtrage**:
  - Par date
  - Par insecte
  - Par niveau de confiance
  - Par champ

- **Détails**:
  - Image analysée
  - Résultat de l'IA
  - Date et heure
  - Localisation
  - Actions prises

---

### 👤 **7. Profil Utilisateur**

#### **Authentification**
- Inscription/Connexion email
- Connexion Google (OAuth)
- Réinitialisation mot de passe

#### **Paramètres**
- Informations personnelles
- Préférences de notification
- Langue de l'interface
- Thème (Clair/Sombre)
- Unités de mesure

#### **Données**
- Synchronisation cloud (Supabase)
- Sauvegarde automatique
- Export des données
- Suppression du compte

---

## 🤖 **INTELLIGENCE ARTIFICIELLE**

### **Architecture Multi-Modèles**

```
┌─────────────────────────────────────┐
│      Utilisateur prend photo        │
└──────────────┬──────────────────────┘
               ↓
┌─────────────────────────────────────┐
│   1️⃣ TensorFlow Lite (Local)       │
│   • Rapide (50-100ms)               │
│   • Privé (on-device)               │
│   • 25 classes d'insectes           │
└──────────────┬──────────────────────┘
               ↓ (si échec)
┌─────────────────────────────────────┐
│   2️⃣ Gemini Vision (Google)        │
│   • Haute précision                 │
│   • Analyse contextuelle            │
│   • Recommandations détaillées      │
└──────────────┬──────────────────────┘
               ↓ (si échec)
┌─────────────────────────────────────┐
│   3️⃣ HuggingFace (Cloud)           │
│   • Modèles spécialisés             │
│   • ResNet architecture             │
└──────────────┬──────────────────────┘
               ↓ (si échec)
┌─────────────────────────────────────┐
│   4️⃣ Model Zoo (Fallback)          │
│   • Garantit toujours une réponse   │
└─────────────────────────────────────┘
```

### **Modèles Utilisés**

1. **TensorFlow Lite**
   - Fichier: `crop_guardian_model.tflite`
   - Taille: ~5 MB
   - Classes: 25 insectes ravageurs
   - Précision: ~85%

2. **Gemini AI**
   - Modèle texte: `gemini-1.5-flash`
   - Modèle vision: `gemini-1.5-flash`
   - API: Google Generative AI

3. **HuggingFace**
   - Modèle: ResNet-50 fine-tuné
   - API: HuggingFace Inference

---

## 🛠️ **TECHNOLOGIES**

### **Frontend**
- **Framework**: Flutter 3.x
- **Langage**: Dart
- **UI**: Material Design 3
- **Navigation**: GoRouter
- **State Management**: Provider

### **Backend & Services**
- **Base de données**: Supabase (PostgreSQL)
- **Authentification**: Supabase Auth + Google OAuth
- **Storage**: Supabase Storage (images)
- **API Météo**: OpenWeatherMap

### **Intelligence Artificielle**
- **TensorFlow Lite**: Inférence locale
- **Google Gemini**: Vision et texte
- **HuggingFace**: Modèles cloud
- **Image Processing**: image package

### **Packages Principaux**
```yaml
dependencies:
  flutter: sdk
  
  # IA & ML
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1
  google_generative_ai: ^0.2.0
  
  # Backend
  supabase_flutter: ^2.0.0
  
  # Caméra & Images
  camera: ^0.10.5
  image_picker: ^1.0.4
  image: ^4.1.3
  
  # Localisation
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Météo
  http: ^1.1.0
  
  # UI
  go_router: ^12.1.1
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  
  # Permissions
  permission_handler: ^11.0.1
```

---

## 📦 **STRUCTURE DU PROJET**

```
lib/
├── core/
│   ├── models/           # Modèles de données
│   │   ├── insect.dart
│   │   ├── field.dart
│   │   ├── infestation.dart
│   │   └── detection.dart
│   │
│   ├── services/         # Services métier
│   │   ├── ai_service.dart              # Orchestrateur IA
│   │   ├── custom_model_service.dart    # TFLite
│   │   ├── gemini_service.dart          # Gemini AI
│   │   ├── huggingface_service.dart     # HuggingFace
│   │   ├── model_zoo_service.dart       # Fallback
│   │   ├── database_service.dart        # Supabase
│   │   ├── weather_service.dart         # Météo
│   │   └── location_service.dart        # GPS
│   │
│   ├── providers/        # State management
│   │   └── auth_provider.dart
│   │
│   ├── router/           # Navigation
│   │   └── app_router.dart
│   │
│   └── widgets/          # Widgets réutilisables
│
├── features/             # Fonctionnalités
│   ├── auth/            # Authentification
│   ├── home/            # Accueil
│   ├── camera/          # Scanner
│   ├── collection/      # Collection d'insectes
│   ├── identification/  # Recherche par description
│   ├── fields/          # Gestion des champs
│   ├── dashboard/       # Tableau de bord
│   ├── weather/         # Météo
│   ├── history/         # Historique
│   ├── detection_result/# Résultats de scan
│   └── profile/         # Profil utilisateur
│
└── main.dart            # Point d'entrée

assets/
├── models/
│   ├── crop_guardian_model.tflite  # Modèle TFLite
│   └── labels.txt                   # Classes d'insectes
│
├── images/              # Images de l'app
└── icons/               # Icônes personnalisées
```

---

## 🚀 **INSTALLATION & CONFIGURATION**

### **Prérequis**
- Flutter SDK 3.0+
- Android Studio / Xcode
- Compte Supabase
- Clé API Google Gemini
- Clé API OpenWeatherMap (optionnel)

### **Installation**

1. **Cloner le projet**
```bash
git clone <repository-url>
cd crop_guardian
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration Supabase**

Créer `.env` à la racine :
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

4. **Configuration Gemini AI**

Dans `lib/core/services/gemini_service.dart` :
```dart
static const String _apiKey = 'VOTRE_CLE_API_GEMINI';
```

5. **Lancer l'application**
```bash
flutter run
```

---

## 📊 **BASE DE DONNÉES**

### **Tables Supabase**

#### **users**
- `id` (UUID, PK)
- `email` (String)
- `name` (String)
- `created_at` (Timestamp)

#### **fields**
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `name` (String)
- `crop_type` (String)
- `area` (Float)
- `latitude` (Float)
- `longitude` (Float)
- `image_url` (String)
- `created_at` (Timestamp)

#### **infestations**
- `id` (UUID, PK)
- `field_id` (UUID, FK)
- `insect_id` (String)
- `insect_name` (String)
- `severity` (String)
- `affected_area` (Float)
- `status` (String)
- `latitude` (Float)
- `longitude` (Float)
- `image_path` (String)
- `notes` (Text)
- `detected_at` (Timestamp)

#### **detections**
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `insect_id` (String)
- `insect_name` (String)
- `confidence` (Float)
- `image_path` (String)
- `created_at` (Timestamp)

---

## 🎨 **DESIGN**

### **Thèmes**
- **Mode Clair**: Design épuré, couleurs naturelles
- **Mode Sombre**: Confort visuel nocturne

### **Couleurs Principales**
- **Primary**: Vert (#4CAF50) - Agriculture
- **Secondary**: Brun (#795548) - Terre
- **Accent**: Orange (#FF9800) - Alertes
- **Error**: Rouge (#F44336) - Danger

### **Typographie**
- **Titres**: Roboto Bold
- **Corps**: Roboto Regular
- **Scientifique**: Roboto Italic

---

## 📱 **CAPTURES D'ÉCRAN**

### Écran d'Accueil
- Accès rapide aux fonctionnalités
- Statistiques en un coup d'œil
- Alertes importantes

### Scanner
- Interface caméra intuitive
- Bouton galerie
- Feedback visuel

### Résultats
- Carte d'information riche
- Niveau de confiance
- Recommandations détaillées
- Actions rapides

### Collection
- Grille d'insectes
- Recherche et filtres
- Détails complets

### Champs
- Liste des champs
- Statut visuel
- Gestion facile

---

## 🔒 **SÉCURITÉ & CONFIDENTIALITÉ**

### **Données Personnelles**
- Chiffrement des communications (HTTPS)
- Authentification sécurisée (Supabase Auth)
- Stockage cloud sécurisé

### **Images**
- Traitement local prioritaire (TFLite)
- Pas de stockage permanent sur serveurs externes
- Suppression automatique après analyse

### **Permissions**
- Caméra: Scan d'insectes
- Galerie: Import d'images
- Localisation: Géolocalisation des champs
- Internet: Synchronisation et IA cloud

---

## 🐛 **INSECTES IDENTIFIABLES**

1. Puceron vert
2. Thrips
3. Mouche blanche
4. Cochenille
5. Doryphore
6. Chenille légionnaire
7. Pyrale du maïs
8. Altise
9. Noctuelle
10. Criquet migrateur
11. Cicadelle
12. Hanneton
13. Taupin
14. Courtilière
15. Tipule
16. Pucerons noirs
17. Acariens
18. Mineuses
19. Chenilles processionnaires
20. Carpocapse
21. Sciarides
22. Aleurodes
23. Psylles
24. Punaises
25. Charançons

---

## 📈 **ROADMAP**

### **Version 1.1** (À venir)
- [ ] Notifications push pour alertes
- [ ] Mode hors-ligne complet
- [ ] Export PDF des rapports
- [ ] Partage entre agriculteurs

### **Version 1.2**
- [ ] Reconnaissance de maladies des plantes
- [ ] Calendrier de traitement
- [ ] Intégration avec drones
- [ ] Analyse de sol

### **Version 2.0**
- [ ] IA prédictive (risques futurs)
- [ ] Marketplace de traitements
- [ ] Communauté d'agriculteurs
- [ ] Support multi-langues

---

## 🤝 **CONTRIBUTION**

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📄 **LICENCE**

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

## 👨‍💻 **AUTEUR**

**Franco**
- GitHub: [@franco](https://github.com/franco)
- Email: franco@example.com

---

## 🙏 **REMERCIEMENTS**

- **Google Gemini** pour l'API d'IA générative
- **TensorFlow** pour le framework ML
- **Supabase** pour le backend
- **Flutter** pour le framework mobile
- **OpenWeatherMap** pour les données météo
- **HuggingFace** pour les modèles ML

---

## 📞 **SUPPORT**

Pour toute question ou problème :
- 📧 Email: support@cropguardian.com
- 💬 Discord: [CropGuardian Community]
- 📱 Twitter: @CropGuardianApp

---

## ⚡ **PERFORMANCES**

### **Temps de Réponse**
- Scan local (TFLite): 50-100ms
- Scan Gemini: 1-3s
- Recherche base de données: <50ms
- Synchronisation cloud: 200-500ms

### **Consommation**
- Batterie: Optimisée pour usage quotidien
- Données: ~5MB par scan cloud
- Stockage: ~50MB (app + modèle)

---

## 🌍 **IMPACT**

CropGuardian aide les agriculteurs à :
- ✅ Identifier rapidement les ravageurs
- ✅ Réduire l'utilisation de pesticides
- ✅ Augmenter les rendements
- ✅ Prendre des décisions éclairées
- ✅ Protéger l'environnement

---

**Version**: 1.0.0  
**Dernière mise à jour**: 7 Novembre 2025  
**Statut**: ✅ Production Ready

---

Made with ❤️ for farmers 🌾
