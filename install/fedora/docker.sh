#!/usr/bin/env bash
set -euo pipefail

echo "🐳 Checking Docker installation..."

# Step 1: Exit early if Docker is already installed
if command -v docker &>/dev/null; then
  echo "✅ Docker is already installed: $(docker --version)"
  exit 0
fi

# Step 2: Install Docker using the official script
echo "⬇️ Installing Docker using get.docker.com script..."
curl -fsSL https://get.docker.com | sh

# Step 3: Enable and start the Docker service
echo "🔧 Starting and enabling Docker service..."
sudo systemctl enable --now docker

# Step 4: Add current user to the docker group
echo "➕ Adding user '$USER' to the docker group..."
sudo usermod -aG docker "$USER"
echo "⚠️  You may need to log out and back in or run 'newgrp docker' for group changes to take effect."

echo "✅ Docker installation and configuration complete!"
