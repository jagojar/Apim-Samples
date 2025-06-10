#!/bin/bash

# ------------------------------
#    PREBUILD OPTIMIZED SETUP
# ------------------------------

set -e

echo "🔧 Running prebuild-optimized setup..."

# Ensure we have proper permissions and environment
export DEBIAN_FRONTEND=noninteractive

# ------------------------------
#    PYTHON ENVIRONMENT SETUP
# ------------------------------

echo "📦 Setting up Python virtual environment..."
# Create virtual environment with proper permissions
sudo mkdir -p /opt/venv
sudo chown vscode:vscode /opt/venv

# Switch to vscode user for virtual environment creation
sudo -u vscode bash << 'VENV_SETUP'
set -e
echo "Creating virtual environment as vscode user..."
python -m venv /opt/venv

echo "Activating virtual environment..."
source /opt/venv/bin/activate

echo "Verifying virtual environment activation..."
which python
python --version

echo "📦 Installing Python dependencies in virtual environment..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

# Ensure pytest and coverage tools are available
pip install pytest pytest-cov coverage

echo "✅ Virtual environment setup complete"
echo "Python location: $(which python)"
echo "Pip location: $(which pip)"
VENV_SETUP

# Activate virtual environment for the rest of the setup
source /opt/venv/bin/activate

# Make virtual environment available system-wide for the vscode user
echo 'export PATH="/opt/venv/bin:$PATH"' >> /home/vscode/.bashrc
echo 'source /opt/venv/bin/activate' >> /home/vscode/.bashrc
echo 'export PATH="/opt/venv/bin:$PATH"' >> /home/vscode/.zshrc  
echo 'source /opt/venv/bin/activate' >> /home/vscode/.zshrc

# Set ownership to vscode user (just to be sure)
sudo chown -R vscode:vscode /opt/venv

echo "🔧 Setting up Python path configuration..."
source /opt/venv/bin/activate
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
source /opt/venv/bin/activate
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
  "python.defaultInterpreterPath": "/opt/venv/bin/python",
  "python.analysis.extraPaths": [
    "/workspaces/Apim-Samples/shared/python"
  ],
  "jupyter.kernels.filter": [
    {
      "path": "/opt/venv/bin/python",
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
#    PREBUILD COMPLETION MARKER
# ------------------------------

echo "✅ Creating prebuild completion marker..."
echo "$(date): Prebuild setup completed" > .devcontainer/.prebuild-complete

echo "🎉 Prebuild setup complete!"

echo "✅ Verifying installation..."
source /opt/venv/bin/activate
echo "Python version: $(python --version)"
echo "Azure CLI version: $(az --version | head -1)"
echo "Pip packages installed:"
pip list | grep -E "(requests|pandas|matplotlib|pytest|azure|jwt|jupyter|ipykernel)" || true

echo ""
echo "🔍 Running comprehensive verification..."
if python .devcontainer/verify-venv.py; then
    echo "✅ Virtual environment verification passed!"
else
    echo "⚠️ Virtual environment verification had issues - but continuing..."
fi

echo "📋 Prebuild optimization complete!"
echo ""
echo "🎯 Next container start should be significantly faster!"
echo "   - Virtual environment: /opt/venv"
echo "   - All packages pre-installed"
echo "   - Ready for immediate development"
