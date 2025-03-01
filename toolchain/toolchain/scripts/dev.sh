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
