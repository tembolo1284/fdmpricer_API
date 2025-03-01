#!/bin/bash
# Python Project Toolchain
# Directory structure:
# - toolchain/
#   - tc            (main CLI script)
#   - scripts/
#     - setup.sh    (setup script)
#     - dev.sh      (dev environment script)
#     - code.sh     (VSCode integration)
#   - templates/
#     - Dockerfile.dev
#     - docker-compose.yml
#     - .devcontainer/
#       - devcontainer.json
#     - .vscode/
#       - settings.json

# Create directory structure
mkdir -p toolchain/scripts toolchain/templates/.devcontainer toolchain/templates/.vscode

# Main CLI tool (tc)
cat > toolchain/tc << 'EOF'
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function show_help {
    echo "Python Toolchain (tc) - Manage Python development environments"
    echo ""
    echo "Commands:"
    echo "  setup    - Install the toolchain and dependencies"
    echo "  dev      - Start a containerized development environment"
    echo "  code     - Open VSCode with the development environment"
    echo "  help     - Show this help message"
    echo ""
}

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

case "$COMMAND" in
    setup)
        "$SCRIPT_DIR/scripts/setup.sh" "$@"
        ;;
    dev)
        "$SCRIPT_DIR/scripts/dev.sh" "$@"
        ;;
    code)
        "$SCRIPT_DIR/scripts/code.sh" "$@"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
EOF
chmod +x toolchain/tc

# Setup script
cat > toolchain/scripts/setup.sh << 'EOF'
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

# Install project dependencies
echo "📦 Installing project dependencies with Poetry..."

# Check if we need to regenerate the lock file
if poetry install 2>&1 | grep -q "The lock file is not compatible"; then
    echo "⚠️ Lock file compatibility issue detected."
    echo "🔄 Regenerating the lock file with poetry lock..."
    poetry lock --no-update
    echo "📦 Now installing dependencies..."
    poetry install
fi

# Create a symlink for the toolchain
echo "🔗 Creating symlink for the toolchain..."
ln -sf "$TOOLCHAIN_DIR/tc" "$PROJECT_DIR/tc"

echo "✅ Setup complete! You can now use the following commands:"
echo "   ./tc dev   - Start a containerized development environment"
echo "   ./tc code  - Open VSCode with the development environment"
EOF
chmod +x toolchain/scripts/setup.sh

# Dev environment script
cat > toolchain/scripts/dev.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(pwd)"

# Check if docker-compose.yml exists
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    echo "❌ No docker-compose.yml found in the current directory."
    echo "   Please run './tc setup' first."
    exit 1
fi

echo "🐳 Starting containerized development environment..."
docker compose up -d

# Check if container was created successfully
if [ $? -eq 0 ]; then
    echo "✅ Development environment is running!"
    echo "   To execute commands inside the container, use:"
    echo "   docker compose exec dev bash"
    echo ""
    echo "   To stop the environment, use:"
    echo "   docker compose down"
else
    echo "❌ Failed to start the development environment."
fi
EOF
chmod +x toolchain/scripts/dev.sh

# VSCode integration script
cat > toolchain/scripts/code.sh << 'EOF'
#!/bin/bash
set -e

PROJECT_DIR="$(pwd)"

# Check if .vscode directory exists
if [ ! -d "$PROJECT_DIR/.vscode" ]; then
    echo "❌ No .vscode directory found in the current directory."
    echo "   Please run './tc setup' first."
    exit 1
fi

# Start the development container if not already running
if ! docker compose ps | grep -q "Up"; then
    echo "🐳 Starting development container..."
    docker compose up -d
fi

# Open VSCode
echo "💻 Opening VSCode..."
code .
EOF
chmod +x toolchain/scripts/code.sh

# Dockerfile template
cat > toolchain/templates/Dockerfile.dev << 'EOF'
FROM python:3.12-slim

# Set environment variables
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    POETRY_VERSION=1.7.1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="${PATH}:/root/.local/bin"

# Set working directory
WORKDIR /app

# Copy pyproject.toml and poetry.lock (if available)
COPY pyproject.toml poetry.lock* ./

# Configure Poetry to not create a virtual environment inside the container
RUN poetry config virtualenvs.create false

# Install dependencies
RUN poetry install --no-interaction --no-ansi

# Copy the rest of the application
COPY . .

# Set the default command
CMD ["bash"]
EOF

# Docker Compose template
cat > toolchain/templates/docker-compose.yml << 'EOF'
version: '3.8'

services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: python_dev_environment
    volumes:
      - .:/app
    ports:
      - "8000:8000"  # Adjust as needed for your application
    stdin_open: true
    tty: true
    command: bash
EOF

# VSCode settings template
mkdir -p toolchain/templates/.vscode
cat > toolchain/templates/.vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "/usr/local/bin/python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "terminal.integrated.profiles.linux": {
        "bash": {
            "path": "bash",
            "icon": "terminal-bash"
        }
    },
    "terminal.integrated.defaultProfile.linux": "bash"
}
EOF

# VS Code devcontainer settings
mkdir -p toolchain/templates/.devcontainer
cat > toolchain/templates/.devcontainer/devcontainer.json << 'EOF'
{
    "name": "Python Development Environment",
    "dockerComposeFile": "../docker-compose.yml",
    "service": "dev",
    "workspaceFolder": "/app",
    "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python",
        "python.formatting.provider": "black",
        "python.linting.enabled": true,
        "python.linting.flake8Enabled": true,
        "python.linting.mypyEnabled": true,
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    },
    "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "njpwerner.autodocstring",
        "ms-azuretools.vscode-docker"
    ],
    "remoteUser": "root"
}
EOF

echo "✅ Python Toolchain created successfully!"
echo ""
echo "To install the toolchain for your project:"
echo "1. Navigate to your project directory"
echo "2. Run: /path/to/toolchain/tc setup"
echo ""
echo "After setup, you can use the following commands in your project directory:"
echo "  ./tc dev   - Start a containerized development environment"
echo "  ./tc code  - Open VSCode with the development environment"
