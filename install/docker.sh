#!/usr/bin/env bash
set -euo pipefail

# Install Docker and Docker Compose using yay
yay -S --noconfirm --needed docker docker-compose

# Ensure the Docker config directory exists
sudo mkdir -p /etc/docker

# Configure Docker to limit log size and avoid disk overuse
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Enable Docker service to start automatically on boot
sudo systemctl enable docker

# Start Docker service immediately
sudo systemctl start docker

# Add the current user to the 'docker' group for permissionless access
sudo usermod -aG docker "${USER}"

# Apply group change immediately for this shell session (may still require logout for full effect)
newgrp docker

echo "✅ Docker installation and setup complete."
