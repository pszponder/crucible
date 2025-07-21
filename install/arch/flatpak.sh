#!/usr/bin/env bash
set -euo pipefail

# Install Flatpak
yay -S --noconfirm --needed flatpak

# Ensure that Flatpak is properly configured and add Flathub repository
echo "Configuring Flatpak and adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Update Flatpak repository
echo "Updating Flatpak repositories..."
flatpak update -y

# List of Flatpak apps to install
flatpak_apps=(
  com.bitwarden.desktop
  # io.podman_desktop.PodmanDesktop
)

# Install the pre-defined Flatpak apps
echo "Installing Flatpak apps..."
for app in "${flatpak_apps[@]}"; do
    echo "Installing $app..."
    flatpak install -y flathub "$app"
done

echo "Flatpak installation and configuration complete!"