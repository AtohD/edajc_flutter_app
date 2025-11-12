# Script PowerShell pour pousser facilement les changements sur GitHub

param(
    [string]$message = "Update"
)

$projectPath = "c:\Flutter Projects\EdajcFlutterApp-main"

# Couleurs pour la sortie
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }

# Vérifications
Write-Info "Vérification de l'environnement..."

if (-not (Test-Path $projectPath)) {
    Write-Error "Chemin du projet non trouvé: $projectPath"
    exit 1
}

cd $projectPath

# Vérifier git
if (-not (Test-Path ".git")) {
    Write-Error "Ce n'est pas un repo Git. Initialise d'abord avec: git init"
    exit 1
}

# Afficher le status
Write-Info "Status Git:"
git status

# Demander confirmation
Write-Info "Message de commit: $message"
$confirm = Read-Host "Continuer ? (O/n)"

if ($confirm -eq "n") {
    Write-Warning "Abandon."
    exit 0
}

# Opérations git
Write-Info "Ajout des fichiers..."
git add .

Write-Info "Commit..."
git commit -m $message

if ($LASTEXITCODE -ne 0) {
    Write-Error "Le commit a échoué"
    exit 1
}

Write-Info "Push vers GitHub..."
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Success "✨ Code pushé avec succès !"
    Write-Info "GitHub Actions va builder l'APK dans ~15 minutes"
    Write-Info "Vérifie: https://github.com/USERNAME/REPO/actions"
} else {
    Write-Error "Le push a échoué. Vérifie tes credentials."
    exit 1
}
