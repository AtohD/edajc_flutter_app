@echo off
REM Script pour pousser le projet sur GitHub et lancer le build APK automatique

echo.
echo ========================================
echo  GitHub Actions - Setup et Premier Push
echo ========================================
echo.

cd "c:\Flutter Projects\EdajcFlutterApp-main"

REM Vérifier si git est installé
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Git n'est pas installé. Télécharge-le depuis https://git-scm.com
    pause
    exit /b 1
)

REM Vérifier si le repo est déjà init
if not exist ".git" (
    echo 📦 Initialisation du repo Git...
    git init
    git add .
    git commit -m "Initial commit - Flutter app avec GitHub Actions"
)

echo.
echo 🔗 Configuration du remote GitHub
echo.
echo Quelle est l'URL de ton repo GitHub ? 
echo (Format: https://github.com/USERNAME/REPO.git)
echo.
set /p github_url="URL: "

if "%github_url%"=="" (
    echo ❌ URL vide. Abandon.
    pause
    exit /b 1
)

REM Vérifier si remote existe déjà
git remote get-url origin >nul 2>nul
if %errorlevel% equ 0 (
    echo ⚠️  Remote 'origin' existe déjà. Mise à jour...
    git remote set-url origin "%github_url%"
) else (
    echo ✅ Ajout du remote origin...
    git remote add origin "%github_url%"
)

echo.
echo 📤 Poussage du code sur GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS ! Le code a été pushé sur GitHub
    echo.
    echo 📊 PROCHAINES ÉTAPES :
    echo.
    echo 1. Va sur: %github_url%
    echo 2. Clique sur l'onglet "Actions"
    echo 3. Attends 10-15 minutes que le build se termine
    echo 4. Télécharge l'APK depuis "Artifacts"
    echo.
    echo Pour les prochaines builds :
    echo - Fais juste: git push origin main
    echo - L'APK sera auto-généré
    echo.
) else (
    echo ❌ Erreur lors du push. Vérifie tes credentials GitHub.
    echo Essaie avec: git push -u origin main
)

pause
