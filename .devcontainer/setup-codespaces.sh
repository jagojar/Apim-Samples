#!/bin/bash

# ------------------------------
#    CODESPACES-COMPATIBLE SETUP
# ------------------------------

set -e
echo "🔧 Running Codespaces-compatible setup..."

# Basic environment setup
export DEBIAN_FRONTEND=noninteractive

# ------------------------------
#    PYTHON VIRTUAL ENVIRONMENT
# ------------------------------

echo "📦 Creating Python virtual environment in user space..."

# Create virtual environment in user home directory (no sudo needed)
VENV_PATH="$HOME/.venv"

if [ ! -d "$VENV_PATH" ]; then
    echo "Creating virtual environment at $VENV_PATH"
    python3 -m venv "$VENV_PATH"
else
    echo "Virtual environment already exists at $VENV_PATH"
fi

# Activate virtual environment
source "$VENV_PATH/bin/activate"

# Install packages in virtual environment
echo "📦 Installing Python packages..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install pytest pytest-cov coverage

# ------------------------------
#    SHELL CONFIGURATION
# ------------------------------

echo "🔧 Configuring shell environment..."

# Add virtual environment activation to bashrc
if ! grep -q "source $VENV_PATH/bin/activate" ~/.bashrc; then
    cat >> ~/.bashrc << EOF

# Virtual environment activation
export VIRTUAL_ENV="$VENV_PATH"
export PATH="$VENV_PATH/bin:\$PATH"
source $VENV_PATH/bin/activate

EOF
fi

# Add virtual environment activation to zshrc (if it exists)
if [ -f ~/.zshrc ]; then
    if ! grep -q "source $VENV_PATH/bin/activate" ~/.zshrc; then
        cat >> ~/.zshrc << EOF

# Virtual environment activation
export VIRTUAL_ENV="$VENV_PATH"
export PATH="$VENV_PATH/bin:\$PATH"
source $VENV_PATH/bin/activate

EOF
    fi
fi

# ------------------------------
#    PYTHON PATH SETUP
# ------------------------------

echo "🔧 Setting up Python path..."
python setup/setup_python_path.py --generate-env || echo "⚠️ Python path setup failed, continuing..."

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
python -m ipykernel install --user --name=apim-samples --display-name="APIM Samples Python" || echo "⚠️ Jupyter kernel setup failed, continuing..."

# ------------------------------
#    WORKSPACE CONFIGURATION
# ------------------------------

echo "🛠️ Configuring workspace..."
mkdir -p .vscode

cat > .vscode/settings.json << EOF
{
  "python.terminal.activateEnvironment": true,
  "python.defaultInterpreterPath": "$VENV_PATH/bin/python",
  "python.analysis.extraPaths": [
    "/workspaces/Apim-Samples/shared/python"
  ],
  "jupyter.kernels.filter": [
    {
      "path": "$VENV_PATH/bin/python",
      "type": "pythonEnvironment"
    }
  ],
  "files.associations": {
    "*.bicep": "bicep"
  },
  "python.envFile": "\${workspaceFolder}/.env"
}
EOF

# ------------------------------
#    COMPLETION
# ------------------------------

echo "✅ Creating completion marker..."
echo "$(date): Codespaces-compatible setup completed" > .devcontainer/.prebuild-complete
echo "Virtual environment path: $VENV_PATH" >> .devcontainer/.prebuild-complete

echo "🎉 Setup complete!"

# Simple verification
echo "✅ Verification:"
echo "Python version: $(python --version)"
echo "Virtual env location: $VENV_PATH"
echo "Packages installed: $(pip list | wc -l) packages"
echo "Python executable: $(which python)"

echo "📋 Setup complete - virtual environment ready!"
echo "💡 Virtual environment will be auto-activated in new terminal sessions"
