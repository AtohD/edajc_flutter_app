#!/bin/bash
# Script de validation - Vérifie que tout est bien configuré

echo "================================================================"
echo "  VALIDATION - GitHub Actions Setup"
echo "================================================================"
echo ""

PROJECT_PATH="c:\Flutter Projects\EdajcFlutterApp-main"
cd "$PROJECT_PATH" || exit 1

# Check 1: Git repo existe
echo "1️⃣  Vérification du repo Git..."
if [ -d ".git" ]; then
    echo "   ✅ Repo Git initialisé"
else
    echo "   ❌ Pas de repo Git - Lance: git init"
    exit 1
fi

# Check 2: GitHub workflow existe
echo ""
echo "2️⃣  Vérification du workflow GitHub Actions..."
if [ -f ".github/workflows/build_apk.yml" ]; then
    echo "   ✅ Workflow trouvé: .github/workflows/build_apk.yml"
else
    echo "   ❌ Workflow manquant"
    exit 1
fi

# Check 3: Documents de support
echo ""
echo "3️⃣  Vérification des documents..."
DOCS=("BUILD_APK_GUIDE_FR.md" "GITHUB_ACTIONS_SETUP.md" "GIT_COMMANDS.md" "QUICK_START.md" "SETUP_CHECKLIST.txt")
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo "   ✅ $doc"
    else
        echo "   ❌ Manquant: $doc"
    fi
done

# Check 4: Scripts
echo ""
echo "4️⃣  Vérification des scripts..."
if [ -f "push_to_github.bat" ]; then
    echo "   ✅ push_to_github.bat (Windows)"
else
    echo "   ⚠️  push_to_github.bat non trouvé"
fi

if [ -f "push.ps1" ]; then
    echo "   ✅ push.ps1 (PowerShell)"
else
    echo "   ⚠️  push.ps1 non trouvé"
fi

# Check 5: Flutter config
echo ""
echo "5️⃣  Vérification de la config Flutter..."
if [ -f "pubspec.yaml" ]; then
    echo "   ✅ pubspec.yaml trouvé"
else
    echo "   ❌ pubspec.yaml manquant"
    exit 1
fi

if [ -f "android/build.gradle" ]; then
    echo "   ✅ android/build.gradle trouvé"
    # Vérifier la version Kotlin
    if grep -q "kotlin_version = '1.7.21'" android/build.gradle; then
        echo "   ✅ Kotlin 1.7.21 (compatible)"
    else
        echo "   ⚠️  Version Kotlin peut être incompatible"
    fi
else
    echo "   ❌ android/build.gradle manquant"
    exit 1
fi

# Check 6: Git remote
echo ""
echo "6️⃣  Vérification du remote Git..."
REMOTE=$(git config --get remote.origin.url)
if [ -n "$REMOTE" ]; then
    echo "   ✅ Remote configuré: $REMOTE"
else
    echo "   ⚠️  Pas de remote configuré - Lance: git remote add origin <URL>"
fi

# Check 7: Lib files (pas d'erreurs Dart)
echo ""
echo "7️⃣  Vérification que lib/ a été analysée..."
if flutter analyze 2>/dev/null | grep -q "No issues found"; then
    echo "   ✅ Pas d'erreurs Dart trouvées"
else
    echo "   ⚠️  Vérifie les erreurs Dart avec: flutter analyze"
fi

# Summary
echo ""
echo "================================================================"
echo "  ✅ VALIDATION COMPLÈTE"
echo "================================================================"
echo ""
echo "Prochaines étapes:"
echo "1. Lance: push_to_github.bat (ou ./push.ps1)"
echo "2. Fournis l'URL de ton repo GitHub"
echo "3. Attends 15 min que GitHub Actions buildera l'APK"
echo "4. Télécharge l'APK depuis GitHub > Actions > Artifacts"
echo ""
echo "Questions? Lis:"
echo "- BUILD_APK_GUIDE_FR.md (guide complet)"
echo "- GIT_COMMANDS.md (commandes Git)"
echo "- QUICK_START.md (démarrage rapide)"
echo ""
