# 🔄 MISES À JOUR FUTURES

## Quand tu as des changements à faire

### Option 1 : Script PowerShell (FACILE)

```powershell
cd "c:\Flutter Projects\EdajcFlutterApp-main"
.\push.ps1 -message "Description de tes changements"
```

Exemple:
```powershell
.\push.ps1 -message "Fix bug page fiches"
```

### Option 2 : Commandes Git

```bash
cd "c:\Flutter Projects\EdajcFlutterApp-main"

# Ajouter les changements
git add .

# Commit
git commit -m "Description courte"

# Push
git push origin main
```

## GitHub Actions buildra automatiquement

1. Tu push le code
2. GitHub Actions reçoit le signal
3. Lance une machine Ubuntu
4. Buildera l'APK en 15 min
5. APK disponible dans Artifacts

## Créer des Releases (versions)

```bash
# Créer un tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push le tag
git push origin v1.0.0
```

Cela va:
- Créer une Release sur GitHub
- Attacher l'APK automatiquement
- Historique de versions clean

## Structure des versions

```
v1.0.0 (Release 1)
  └─ app-release-v1.0.0.apk

v1.0.1 (Bugfix)
  └─ app-release-v1.0.1.apk

v1.1.0 (Feature release)
  └─ app-release-v1.1.0.apk
```

## Tester localement avant de push

```bash
# Sur émulateur/device
flutter run

# Build web
flutter build web --release

# Run sur desktop
flutter run -d windows
```

## Voir l'historique

```bash
# Voir les commits
git log --oneline

# Voir les tags
git tag -l

# Voir les branches
git branch -a
```

## Troubleshooting

**"Error: git not found"**
- Installe Git: https://git-scm.com/download/win

**"Error: Permission denied"**
- Vérifie tes credentials GitHub
- Réinitialise avec: git config --list

**"APK build failed on GitHub Actions"**
- Lit les logs: GitHub > Actions > Clique sur le workflow rouge
- Les erreurs sont en bas des logs

## Bonnes pratiques

✅ Commit souvent (petits commits)
✅ Messages clairs ("Fix X" pas "asdasd")
✅ Une branche par feature (optionnel)
✅ Tag les releases importantes
✅ Lis les logs si erreur

## Exemple workflow réaliste

```bash
# Le matin: Lancer le dev
git checkout main
git pull origin main
flutter pub get

# Pendant la journée: Faire des changements
# ... code code code ...

# À la fin: Push les changements
git add .
git commit -m "Ajout nouvelle page"
git push origin main

# Attendre 15 min que GitHub buildera

# Télécharger l'APK depuis GitHub

# Tester sur vrai téléphone
adb install app-release.apk
```

## Documentation

Si tu as besoin de rappels:
- GIT_COMMANDS.md - Toutes les commandes
- GITHUB_ACTIONS_SETUP.md - Details techniques
- BUILD_APK_GUIDE_FR.md - Guide complet

---

**C'est tout !** Les mises à jour c'est juste `push_to_github.bat` ou `git push` 🚀
