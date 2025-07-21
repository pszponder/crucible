#!/usr/bin/env bash
set -euo pipefail

# Install Docker Desktop using yay
yay -S --noconfirm --needed docker-desktop

# Ensure the docker group exists, and add current user if needed
sudo groupadd -f docker  # Create the group if it doesn't exist

# Check if the user is already in the docker group and if not, add them
if ! groups "${USER}" | grep -q '\bdocker\b'; then
  echo "Adding user ${USER} to the docker group..."
  sudo usermod -aG docker "${USER}"
fi

# Enable Docker and Docker Desktop services
sudo systemctl enable docker.service
sudo systemctl start docker.service

sudo systemctl enable docker-desktop.service
sudo systemctl start docker-desktop.service

echo "✅ Docker Desktop installation and setup complete."
echo "⚠️ Please log out and back in to use Docker Desktop without sudo."
