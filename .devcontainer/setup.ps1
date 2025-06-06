# PowerShell Setup Script for APIM Samples Dev Container
# This script mirrors the functionality of setup.sh for Windows environments

# ------------------------------
#    DEVCONTAINER SETUP SCRIPT
# ------------------------------

Write-Host "🚀 Setting up APIM Samples development environment..." -ForegroundColor Green

# ------------------------------
#    PYTHON ENVIRONMENT SETUP
# ------------------------------

Write-Host "📦 Installing Python dependencies..." -ForegroundColor Yellow
python -m pip install --upgrade pip
pip install -r requirements.txt

# Ensure pytest and coverage tools are available
pip install pytest pytest-cov coverage

Write-Host "🔧 Setting up Python path configuration..." -ForegroundColor Yellow
python setup/setup_python_path.py --generate-env

# ------------------------------
#    AZURE CLI SETUP
# ------------------------------

Write-Host "☁️ Configuring Azure CLI..." -ForegroundColor Yellow
# Set Azure CLI to use device code flow by default in codespaces/containers
try {
    az config set core.login_experience_v2=off 2>$null
} catch {
    # Ignore errors if config setting fails
}

# Install additional Azure CLI extensions that might be useful
Write-Host "📥 Installing Azure CLI extensions..." -ForegroundColor Yellow
try {
    az extension add --name containerapp --only-show-errors 2>$null
    az extension add --name front-door --only-show-errors 2>$null
} catch {
    Write-Host "⚠️ Some Azure CLI extensions could not be installed" -ForegroundColor Yellow
}

# ------------------------------
#    JUPYTER SETUP
# ------------------------------

Write-Host "📓 Setting up Jupyter environment..." -ForegroundColor Yellow
# Install Jupyter kernel
python -m ipykernel install --user --name=apim-samples --display-name="APIM Samples Python"

# ------------------------------
#    WORKSPACE CONFIGURATION
# ------------------------------

Write-Host "🛠️ Configuring workspace settings..." -ForegroundColor Yellow

# Create .vscode directory if it doesn't exist
if (-not (Test-Path ".vscode")) {
    New-Item -ItemType Directory -Path ".vscode" -Force
}

# Create settings.json for the workspace
$settingsJson = @'
{
  "python.terminal.activateEnvironment": true,
  "python.defaultInterpreterPath": "python",
  "jupyter.kernels.filter": [
    {
      "path": "python",
      "type": "pythonEnvironment"
    }
  ],
  "files.associations": {
    "*.bicep": "bicep"
  },
  "python.envFile": "${workspaceFolder}/.env"
}
'@

$settingsJson | Out-File -FilePath ".vscode/settings.json" -Encoding UTF8

# ------------------------------
#    FINAL VERIFICATION
# ------------------------------

Write-Host "✅ Verifying installation..." -ForegroundColor Green

Write-Host "Python version:" -ForegroundColor Cyan
python --version

Write-Host "Azure CLI version:" -ForegroundColor Cyan
$azVersion = az --version | Select-Object -First 1
Write-Host $azVersion

Write-Host "Pip packages installed:" -ForegroundColor Cyan
pip list | Select-String -Pattern "(requests|pandas|matplotlib|pytest|azure|jwt)"

Write-Host "🎉 Development environment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Sign in to Azure: az login"
Write-Host "2. Execute shared/jupyter/verify-az-account.ipynb to verify your Azure setup"
Write-Host "3. Navigate to any infrastructure folder and run the create.ipynb notebook"
Write-Host "4. Explore the samples in the samples/ directory"
Write-Host ""
Write-Host "💡 Tip: The Python path has been configured to include shared/python modules automatically." -ForegroundColor Cyan
