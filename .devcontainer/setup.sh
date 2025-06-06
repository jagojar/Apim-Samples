#!/bin/bash

# ------------------------------
#    DEVCONTAINER SETUP SCRIPT
# ------------------------------

set -e

echo "🚀 Setting up APIM Samples development environment..."

# ------------------------------
#    PYTHON ENVIRONMENT SETUP
# ------------------------------

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Ensure pytest and coverage tools are available
pip install pytest pytest-cov coverage

echo "🔧 Setting up Python path configuration..."
python setup/setup_python_path.py --generate-env

# ------------------------------
#    AZURE CLI SETUP
# ------------------------------

echo "☁️ Configuring Azure CLI..."
# Set Azure CLI to use device code flow by default in codespaces/containers
az config set core.login_experience_v2=off 2>/dev/null || true

# Install additional Azure CLI extensions that might be useful
echo "📥 Installing Azure CLI extensions..."
az extension add --name containerapp --only-show-errors 2>/dev/null || true
az extension add --name front-door --only-show-errors 2>/dev/null || true

# ------------------------------
#    JUPYTER SETUP
# ------------------------------

echo "📓 Setting up Jupyter environment..."
# Install Jupyter kernel (with error handling)
if python -c "import ipykernel" 2>/dev/null; then
    python -m ipykernel install --user --name=apim-samples --display-name="APIM Samples Python" || echo "⚠️ Warning: Failed to install Jupyter kernel, but continuing..."
else
    echo "⚠️ Warning: ipykernel not found. Installing it now..."
    pip install ipykernel
    python -m ipykernel install --user --name=apim-samples --display-name="APIM Samples Python" || echo "⚠️ Warning: Failed to install Jupyter kernel, but continuing..."
fi

# ------------------------------
#    WORKSPACE CONFIGURATION
# ------------------------------

echo "🛠️ Configuring workspace settings..."

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Create settings.json for the workspace
cat > .vscode/settings.json << 'EOF'
{
  "python.terminal.activateEnvironment": true,
  "python.defaultInterpreterPath": "/usr/local/bin/python",
  "jupyter.kernels.filter": [
    {
      "path": "/usr/local/bin/python",
      "type": "pythonEnvironment"
    }
  ],
  "files.associations": {
    "*.bicep": "bicep"
  },
  "python.envFile": "${workspaceFolder}/.env"
}
EOF

# ------------------------------
#    FINAL VERIFICATION
# ------------------------------

echo "✅ Verifying installation..."

echo "Python version:"
python --version

echo "Azure CLI version:"
az --version | head -1

echo "Pip packages installed:"
pip list | grep -E "(requests|pandas|matplotlib|pytest|azure|jwt|jupyter|ipykernel)"

echo "Jupyter kernels available:"
jupyter kernelspec list 2>/dev/null || echo "⚠️ Jupyter kernels could not be listed"

echo "🎉 Development environment setup complete!"

echo "🔍 Running final verification..."
python .devcontainer/verify-setup.py

echo ""
echo "📋 Next steps:"
echo "1. Sign in to Azure: az login"
echo "2. Execute shared/jupyter/verify-az-account.ipynb to verify your Azure setup"
echo "3. Navigate to any infrastructure folder and run the create.ipynb notebook"
echo "4. Explore the samples in the samples/ directory"
echo ""
echo "💡 Tip: The Python path has been configured to include shared/python modules automatically."
