# 📚 COMMANDES GIT ESSENTIELLES

## Premier Push (une seule fois)

```bash
cd "c:\Flutter Projects\EdajcFlutterApp-main"

# Initialiser le repo local
git init

# Ajouter tous les fichiers
git add .

# Commit initial
git commit -m "Initial commit - Flutter app"

# Ajouter le remote GitHub
git remote add origin https://github.com/USERNAME/REPO.git

# Pousser sur main
git push -u origin main
```

**OU utiliser le script automatique :**
```bash
./push_to_github.bat
```

---

## Modifications futures (à chaque changement)

```bash
# Ajouter les fichiers modifiés
git add .

# Commit avec message
git commit -m "Description courte des changements"

# Pousser sur GitHub
git push origin main
```

---

## Créer une Release (pour les versions officielles)

```bash
# Créer un tag de version
git tag -a v1.0.0 -m "Release version 1.0.0"

# Pousser le tag
git push origin v1.0.0
```

Cela va créer une **Release** sur GitHub avec l'APK attaché.

---

## Vérifier l'état

```bash
# Voir les modifications non commitées
git status

# Voir l'historique des commits
git log --oneline

# Voir les remotes
git remote -v

# Voir les tags
git tag -l
```

---

## En cas de problème

```bash
# Annuler les changements non commitées
git restore .

# Voir la config
git config --list

# Changer le remote URL
git remote set-url origin https://github.com/USERNAME/NEW_REPO.git

# Voir les erreurs de push
git push -v
```

---

## Structure Git typique

```
EdajcFlutterApp (main branch)
├── lib/
├── android/
├── ios/
├── .github/
│   └── workflows/
│       └── build_apk.yml
├── pubspec.yaml
└── ... autres fichiers
```

À chaque `git push origin main`, GitHub Actions va :
1. Récupérer le code
2. Compiler l'APK
3. Uploader comme artifact
4. ✅ Prêt à télécharger

---

## Setup GitHub SSH (optionnel, plus secure)

Si tu veux éviter d'entrer ton mot de passe à chaque push :

```bash
# 1. Générer une clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github

# 2. Copier la clé publique
cat ~/.ssh/github.pub

# 3. La coller dans GitHub Settings > SSH Keys

# 4. Utiliser l'URL SSH
git remote set-url origin git@github.com:USERNAME/REPO.git

# 5. Tester
git push origin main
```

---

## Commandes rapides

| Commande | Description |
|----------|------------|
| `git add .` | Stage tous les fichiers |
| `git commit -m "msg"` | Commit avec message |
| `git push origin main` | Pousser sur GitHub |
| `git pull origin main` | Tirer les changements |
| `git status` | État du repo |
| `git log --oneline` | Historique |
| `git tag -a v1.0 -m "msg"` | Créer un tag |
| `git push origin v1.0` | Pousser le tag |

---

C'est tout ! Questions = lis BUILD_APK_GUIDE_FR.md
