#!/bin/bash

# ------------------------------
#    SIMPLE PREBUILD SETUP
# ------------------------------

set -e
echo "🔧 Running simplified prebuild setup..."

# Basic environment setup
export DEBIAN_FRONTEND=noninteractive

# ------------------------------
#    PYTHON VIRTUAL ENVIRONMENT
# ------------------------------

echo "📦 Creating Python virtual environment..."

# Create venv directory with proper permissions
if [ ! -d "/opt/venv" ]; then
    sudo mkdir -p /opt/venv
    sudo chown -R vscode:vscode /opt/venv
fi

# Create virtual environment as vscode user
sudo -u vscode python3 -m venv /opt/venv

# Install packages in virtual environment
echo "📦 Installing Python packages..."
sudo -u vscode /opt/venv/bin/pip install --upgrade pip setuptools wheel
sudo -u vscode /opt/venv/bin/pip install -r requirements.txt
sudo -u vscode /opt/venv/bin/pip install pytest pytest-cov coverage

# Ensure ownership is correct
sudo chown -R vscode:vscode /opt/venv

# ------------------------------
#    SHELL CONFIGURATION
# ------------------------------

echo "🔧 Configuring shell environment..."

# Create bashrc additions for vscode user
sudo -u vscode bash -c 'cat >> ~/.bashrc << "EOF"

# Virtual environment activation
export VIRTUAL_ENV="/opt/venv"
export PATH="/opt/venv/bin:$PATH"
source /opt/venv/bin/activate

EOF'

# Create zshrc additions for vscode user  
sudo -u vscode bash -c 'cat >> ~/.zshrc << "EOF"

# Virtual environment activation
export VIRTUAL_ENV="/opt/venv"
export PATH="/opt/venv/bin:$PATH"
source /opt/venv/bin/activate

EOF'

# ------------------------------
#    PYTHON PATH SETUP
# ------------------------------

echo "🔧 Setting up Python path..."
sudo -u vscode /opt/venv/bin/python setup/setup_python_path.py --generate-env || echo "⚠️ Python path setup failed, continuing..."

# ------------------------------
#    AZURE CLI SETUP
# ------------------------------

echo "☁️ Configuring Azure CLI..."
az config set core.login_experience_v2=off 2>/dev/null || true

echo "📥 Installing Azure CLI extensions..."
az extension add --name containerapp --only-show-errors 2>/dev/null || true
az extension add --name front-door --only-show-errors 2>/dev/null || true

# ------------------------------
#    JUPYTER SETUP
# ------------------------------

echo "📓 Setting up Jupyter..."
sudo -u vscode /opt/venv/bin/python -m ipykernel install --user --name=apim-samples --display-name="APIM Samples Python" || echo "⚠️ Jupyter kernel setup failed, continuing..."

# ------------------------------
#    WORKSPACE CONFIGURATION
# ------------------------------

echo "🛠️ Configuring workspace..."
mkdir -p .vscode

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
#    COMPLETION
# ------------------------------

echo "✅ Creating completion marker..."
echo "$(date): Simplified prebuild setup completed" > .devcontainer/.prebuild-complete

echo "🎉 Prebuild setup complete!"

# Simple verification
echo "✅ Verification:"
echo "Python version: $(/opt/venv/bin/python --version)"
echo "Virtual env location: /opt/venv"
echo "Packages installed: $(/opt/venv/bin/pip list | wc -l) packages"

echo "📋 Setup complete - container should start faster next time!"
