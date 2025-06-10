#!/usr/bin/env python3
"""
Verification script to ensure virtual environment and packages are properly installed.
"""
import sys
import subprocess
import importlib

# ------------------------------
#    CONSTANTS
# ------------------------------

REQUIRED_PACKAGES = [
    'requests',
    'setuptools', 
    'pandas',
    'matplotlib',
    'jwt',
    'pytest',
    'azure.storage.blob',
    'azure.identity',
    'jupyter',
    'ipykernel',
    'notebook'
]

# ------------------------------
#    PUBLIC METHODS
# ------------------------------

def check_virtual_environment():
    """Check if we're running in the expected virtual environment."""
    import os
    expected_venv_locations = [
        os.path.expanduser('~/.venv'),
        '/opt/venv'
    ]
    
    current_prefix = sys.prefix
    
    for expected_venv in expected_venv_locations:
        if expected_venv in current_prefix:
            print(f"✅ Running in virtual environment: {current_prefix}")
            return True
    
    print(f"❌ Not running in expected virtual environment. Current: {current_prefix}")
    print(f"Expected one of: {expected_venv_locations}")
    return False

def check_package_imports():
    """Check if all required packages can be imported."""
    failed_imports = []
    
    for package in REQUIRED_PACKAGES:
        try:
            importlib.import_module(package)
            print(f"✅ {package}")
        except ImportError:
            print(f"❌ {package}")
            failed_imports.append(package)
    
    return len(failed_imports) == 0

def check_executables():
    """Check if Python executables are correctly configured."""
    import os
    try:
        python_path = subprocess.check_output(['which', 'python'], text=True).strip()
        pip_path = subprocess.check_output(['which', 'pip'], text=True).strip()
        
        print(f"✅ Python executable: {python_path}")
        print(f"✅ Pip executable: {pip_path}")
        
        expected_venv_locations = [
            os.path.expanduser('~/.venv'),
            '/opt/venv'
        ]
        
        for expected_venv in expected_venv_locations:
            if expected_venv in python_path and expected_venv in pip_path:
                return True
        
        print(f"⚠️ Executables not in expected virtual environment locations: {expected_venv_locations}")
        return False
    except subprocess.CalledProcessError:
        print("❌ Failed to locate Python or pip executables")
        return False

def main():
    """Main verification function."""
    print("🔍 Verifying virtual environment setup...\n")
    
    checks = [
        ("Virtual Environment", check_virtual_environment),
        ("Package Imports", check_package_imports),
        ("Executables", check_executables)
    ]
    
    all_passed = True
    
    for check_name, check_func in checks:
        print(f"\n📋 {check_name} Check:")
        if not check_func():
            all_passed = False
    
    print(f"\n{'✅ All checks passed!' if all_passed else '❌ Some checks failed!'}")
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    sys.exit(main())
