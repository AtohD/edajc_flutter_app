# 🎯 BUILD APK AUTOMATIQUE - Guide Complet

## Problème résolu ✅

Comme tu ne peux pas compiler l'APK sur Windows (bug Kotlin Flutter 3.35.6), **GitHub Actions le fait pour toi automatiquement** sur Ubuntu (gratuit).

---

## 🚀 Setup en 5 minutes

### **Étape 1 : Avoir un compte GitHub**
- Crée un compte sur https://github.com (gratuit)
- Crée un nouveau repo (privé ou public)

### **Étape 2 : Exécuter le script de push**

```bash
cd "c:\Flutter Projects\EdajcFlutterApp-main"
./push_to_github.bat
```

Le script va te demander l'URL de ton repo GitHub, puis poussera le code automatiquement.

**Exemple d'URL :**
```
https://github.com/tautohd/EdajcFlutterApp.git
```

### **Étape 3 : Vérifier que GitHub Actions fonctionne**

1. Va sur ton repo GitHub
2. Clique sur l'onglet **"Actions"**
3. Tu verras **"Build APK Release"** qui tourne (orange = en cours)
4. Attends 10-15 minutes
5. Quand c'est ✅ vert, l'APK est prêt

### **Étape 4 : Télécharger l'APK**

**Option A : Depuis les Artifacts**
- Clique sur le workflow qui vient de finir
- Scroll down jusqu'à **"Artifacts"**
- Télécharge `app-release.apk`

**Option B : Créer une Release (avec version)**
```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```
Cela crée une Release GitHub avec l'APK attaché.

---

## 📊 Ce qui se passe automatiquement

Chaque fois que tu fais `git push origin main` :

1. ✅ GitHub Actions détecte le push
2. ✅ Lance une machine Ubuntu
3. ✅ Installe Flutter 3.24.5 (sans bug Kotlin)
4. ✅ Récupère tes dépendances
5. ✅ Lance `flutter build apk --release`
6. ✅ L'APK est généré et prêt à télécharger
7. ✅ Tout ça en 10-15 minutes

---

## 🔄 Workflow typique

```bash
# Faire des modifications locales
# ...

# Committer les changements
git add .
git commit -m "Ajout feature X"

# Pousser sur GitHub
git push origin main

# Attendre 10-15 min que GitHub Actions buildera l'APK
# Télécharger l'APK depuis GitHub
```

---

## 📝 Fichiers créés

- `.github/workflows/build_apk.yml` - Configuration GitHub Actions
- `push_to_github.bat` - Script pour premier push (Windows)
- `GITHUB_ACTIONS_SETUP.md` - Documentation détaillée

---

## ⚙️ Customization (optionnel)

Si tu veux modifier le workflow (ex: version Flutter différente) :

1. Ouvre `.github/workflows/build_apk.yml`
2. Change `flutter-version: '3.24.5'` vers la version que tu veux
3. Commit et push
4. C'est tout !

---

## ❓ Questions fréquentes

**Q: Combien de temps ça prend ?**
A: 10-15 minutes pour builder l'APK

**Q: C'est gratuit ?**
A: Oui, GitHub Actions gratuit = 2000 minutes/mois (plus que suffisant)

**Q: Ça marche si mon repo est privé ?**
A: Oui, GitHub Actions fonctionne pour repos privés aussi

**Q: Comment tester localement avant de pousser ?**
A: `flutter run` sur émulateur/device (pas besoin de build APK pour tester)

**Q: Et si le build échoue ?**
A: Va dans GitHub > Actions > Clique sur le workflow > Lis les logs rouges

---

## 🎉 C'est fini !

Maintenant tu peux exporter ton app Android sans te soucier du bug Kotlin Windows.

À chaque push, GitHub Actions buildera l'APK pour toi. ✅
