# 🚀 GitHub Actions - Build APK Automatique

## Configuration GitHub Actions pour Flutter

Ce projet est maintenant configuré pour builder l'APK automatiquement via **GitHub Actions** sur Ubuntu (sans le bug Kotlin de Windows).

### 📦 Comment ça fonctionne

Le workflow `.github/workflows/build_apk.yml` :
- ✅ S'exécute automatiquement à chaque **push** sur les branches `main`, `master`, `develop`
- ✅ Génère l'APK en mode **release**
- ✅ Télécharge l'APK comme **artifact** (téléchargeable dans GitHub)
- ✅ Crée une **Release** et attache l'APK si tu utilises des **tags Git**

### 🔧 Installation / Setup

#### **Étape 1 : Pousser le code sur GitHub**

```bash
cd "c:\Flutter Projects\EdajcFlutterApp-main"

# Initialiser git (si pas déjà fait)
git init
git add .
git commit -m "initial commit avec workflow GitHub Actions"

# Ajouter le remote GitHub (remplace USER et REPO)
git remote add origin https://github.com/USER/REPO.git

# Pousser le code
git push -u origin main
```

#### **Étape 2 : Vérifier que GitHub Actions fonctionne**

1. Va sur ton repo GitHub : `https://github.com/USER/REPO`
2. Clique sur l'onglet **"Actions"**
3. Tu verras le workflow `Build APK Release` qui tourne
4. Attends 10-15 minutes que le build se termine

#### **Étape 3 : Télécharger l'APK**

**Option A : Via Artifacts (après chaque push)**
1. Clique sur le workflow qui vient de finir
2. Descends jusqu'à "Artifacts"
3. Clique sur `app-release` pour télécharger l'APK

**Option B : Via Release (quand tu cères un tag)**
```bash
# Créer un tag de version
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```
Cela va créer une **Release** avec l'APK attaché automatiquement.

### 📋 Configuration du workflow

Le fichier `.github/workflows/build_apk.yml` utilise :
- **Ubuntu** (sans bug Kotlin comme Windows)
- **Flutter 3.24.5** (version stable compatible)
- **Java 17** (pour Gradle)
- **Dart** (inclus avec Flutter)

### ⚙️ Personnalisations

Si tu veux modifier le workflow :

- **Changer la version Flutter** : Modifie `flutter-version: '3.24.5'` dans `build_apk.yml`
- **Ajouter des branches** : Modifie `branches: [ main, master, develop ]`
- **Déclencher manuellement** : Va dans "Actions" → "Build APK Release" → "Run workflow"

### 🔑 Secrets / Configuration

Le workflow utilise automatiquement `secrets.GITHUB_TOKEN` pour :
- Uploader l'APK comme artifact
- Créer des Releases (si tu utilises des tags)

**Aucune configuration manuelle requise.**

### 📊 Exemple de sortie

Quand le build réussit, tu verras :
```
✅ Build APK
✅ Upload APK to Release
✅ Artifacts ready for download
```

### ❓ Troubleshooting

**"Action fails with error X"** → Va dans l'onglet "Actions", clique sur le workflow qui a échoué, et lis les logs détaillés.

**"APK artifact not found"** → C'est que le build APK a échoué. Vérifie les erreurs Dart dans les logs.

---

## Résumé rapide

```bash
# Pousse le code
git push origin main

# Attends 10-15 min
# Télécharge l'APK depuis GitHub Actions > Artifacts
```

C'est tout ! 🎉
