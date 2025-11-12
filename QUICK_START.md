# 🚀 QUICK START - EdajcFlutterApp

## 📋 Pré-requis

- Flutter 3.24.5 (ou plus récent)
- Dart SDK (inclus avec Flutter)
- Android SDK / Emulator
- VS Code ou Android Studio
- Git

## 🎯 Installation rapide

### 1. Cloner le repo
```bash
git clone https://github.com/USER/EdajcFlutterApp.git
cd EdajcFlutterApp
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Lancer l'app localement
```bash
# Sur émulateur/device
flutter run

# Ou mode debug
flutter run -d emulator-5554
```

## 📱 Build APK

### Build sur GitHub Actions (RECOMMANDÉ)

1. Push le code sur GitHub
2. Attends 10-15 min
3. Télécharge l'APK depuis GitHub > Actions > Artifacts

**Documentation complète :** Lis `BUILD_APK_GUIDE_FR.md`

### Build local (si tu as une autre machine)

```bash
flutter clean
flutter pub get
flutter build apk --release
```

L'APK sera ici : `build/app/outputs/flutter-apk/app-release.apk`

## 🔥 Stack technologique

- **Frontend :** Flutter (Dart)
- **Backend :** Firebase (Auth, Firestore, Storage)
- **State Management :** Provider, ValueNotifier
- **UI :** Material Design 3
- **Desktop :** Window Manager
- **Localization :** intl

## 📂 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée
├── routes.dart              # Navigation
├── pages/                   # Pages de l'app
│   ├── fiches/             # Suivi pédagogique
│   ├── user_management_page/
│   ├── inbox/              # Évaluations
│   └── form/               # Formulaires
├── controllers/            # Logique métier
├── models/                 # Modèles Dart
├── providers/              # State management
├── services/               # Firebase, API
├── widgets/                # Composants réutilisables
└── core/                   # Utils, Theme, Config
```

## 🔑 Configuration Firebase

1. Crée un projet Firebase
2. Configure `lib/firebase_options.dart`
3. Ajoute Google Services JSON pour Android
4. Définir les règles Firestore

**Règles Firestore :** Voir commentaires dans le code

## 🧪 Tests

```bash
# Lancer les tests
flutter test

# Avec couverture
flutter test --coverage
```

## 📊 Linter & Analyzer

```bash
# Vérifier les erreurs
flutter analyze

# Formater le code
dart format .

# Fix automatique
dart fix --apply
```

## 🚀 Déploiement

### Android APK
```bash
# Via GitHub Actions (recommandé)
git push origin main
# Attendre 15 min → Télécharger APK

# Ou localement
flutter build apk --release
```

### Web
```bash
flutter build web --release
# Fichiers dans: build/web/
```

### iOS (sur Mac)
```bash
flutter build ios --release
```

## 🐛 Troubleshooting

**"Flutter command not found"**
```bash
# Ajouter Flutter au PATH
export PATH="$PATH:~/flutter/bin"
```

**"Error building APK"**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release
```

**"Firestore permission denied"**
- Vérifie les règles Firestore
- Assure-toi d'être authentifié
- Voir `lib/pages/fiches/fiche_suivi_ame_Widget.dart`

## 📞 Support

- Lire `BUILD_APK_GUIDE_FR.md` pour les APK builds
- Lire `GIT_COMMANDS.md` pour les commandes Git
- Lire `GITHUB_ACTIONS_SETUP.md` pour GitHub Actions

## 📝 Changelog

### Version 1.0.0
- ✅ Setup complet avec GitHub Actions
- ✅ Firestore rules alignement
- ✅ Role-based UI filtering
- ✅ Dart analyzer errors fixed
- ✅ Documentation française

## 📄 License

Voir LICENSE.md

---

**Questions ?** Ouvre une issue sur GitHub ou lis la documentation dans le repo.

Bonne coding ! 🎉
