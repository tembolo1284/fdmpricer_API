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
