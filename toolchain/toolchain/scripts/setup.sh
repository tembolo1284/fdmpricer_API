#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLCHAIN_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"

echo "🔧 Setting up Python toolchain for: $PROJECT_DIR"

# Check if Poetry is installed, install if not
if ! command -v poetry &> /dev/null; then
    echo "📦 Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker is not installed. Please install Docker to use the containerized development environment."
    echo "📝 Visit https://docs.docker.com/get-docker/ for installation instructions."
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "⚠️ Docker Compose is not installed. Please install Docker Compose to use the containerized development environment."
    echo "📝 Visit https://docs.docker.com/compose/install/ for installation instructions."
fi

# Check if pyproject.toml exists
if [ ! -f "$PROJECT_DIR/pyproject.toml" ]; then
    echo "⚠️ No pyproject.toml found in the current directory."
    read -p "Would you like to create one? (y/n): " create_pyproject
    
    if [[ "$create_pyproject" =~ ^[Yy]$ ]]; then
        echo "📝 Setting up a new Poetry project..."
        poetry new --name=$(basename "$PROJECT_DIR") .
    else
        echo "❌ Cannot proceed without pyproject.toml"
        exit 1
    fi
fi

# Copy Docker templates
echo "🐳 Setting up Docker development environment..."
cp "$TOOLCHAIN_DIR/templates/Dockerfile.dev" "$PROJECT_DIR/Dockerfile.dev"
cp "$TOOLCHAIN_DIR/templates/docker-compose.yml" "$PROJECT_DIR/docker-compose.yml"

# Set up VS Code integration
echo "💻 Setting up VS Code integration..."
mkdir -p "$PROJECT_DIR/.vscode" "$PROJECT_DIR/.devcontainer"
cp "$TOOLCHAIN_DIR/templates/.vscode/settings.json" "$PROJECT_DIR/.vscode/settings.json"
cp "$TOOLCHAIN_DIR/templates/.devcontainer/devcontainer.json" "$PROJECT_DIR/.devcontainer/devcontainer.json"

# Handle Poetry dependency installation with better error handling and verbosity
echo "📦 Installing project dependencies with Poetry..."
echo "🔍 First, checking Poetry configuration..."
poetry config --list

echo "🔍 Checking if lock file exists..."
if [ -f "$PROJECT_DIR/poetry.lock" ]; then
    echo "🔄 Lock file exists, checking compatibility..."
    
    # Try to install, capture output to check for compatibility issues
    install_output=$(poetry install 2>&1) || true
    
    if echo "$install_output" | grep -q "lock file is not compatible"; then
        echo "⚠️ Lock file compatibility issue detected."
        echo "🔄 Regenerating the lock file with poetry lock..."
        poetry lock --no-update -v
    elif echo "$install_output" | grep -q "No module named"; then
        echo "⚠️ Dependency resolution issue detected."
        echo "🔄 Regenerating the lock file..."
        rm -f poetry.lock
        poetry lock -v
    fi
else
    echo "🔄 No lock file found, generating one..."
    poetry lock -v
fi

echo "📦 Now installing dependencies (this may take a few minutes)..."
echo "   You can press Ctrl+C to cancel if it takes too long"
echo "   and then run 'poetry install' manually."

# Try to install with a timeout if available
if command -v timeout &> /dev/null; then
    timeout 300 poetry install -v || echo "⚠️ Poetry install timed out after 5 minutes. You may need to run it manually."
else
    poetry install -v || echo "⚠️ Poetry install failed. You may need to run it manually."
fi

# Create a symlink for the toolchain
echo "🔗 Creating symlink for the toolchain..."
ln -sf "$TOOLCHAIN_DIR/tc" "$PROJECT_DIR/tc"

echo "✅ Setup complete! You can now use the following commands:"
echo "   ./tc dev   - Start a containerized development environment"
echo "   ./tc code  - Open VSCode with the development environment"
