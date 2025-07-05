#!/usr/bin/env bash
set -euo pipefail

# Detect Linux distribution
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# Install Flatpak if it's not installed
install_flatpak_if_missing() {
  if command -v flatpak >/dev/null 2>&1; then
    echo "✅ Flatpak is already installed."
    return
  fi

  DISTRO=$(detect_distro)
  echo "📦 Installing Flatpak for distro: $DISTRO"

  case "$DISTRO" in
    ubuntu | debian)
      sudo apt update
      sudo apt install -y flatpak
      ;;
    fedora)
      sudo dnf install -y flatpak
      ;;
    arch | manjaro)
      sudo pacman -S --noconfirm --needed flatpak
      ;;
    *)
      echo "❌ Unsupported distro. Please install Flatpak manually."
      exit 1
      ;;
  esac
}

# Add Flathub remote if it's not already configured
configure_flathub() {
  if flatpak remote-list | grep -q flathub; then
    echo "✅ Flathub is already configured."
  else
    echo "🔗 Adding Flathub remote..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
}

# 🧭 Main
install_flatpak_if_missing
configure_flathub

echo "✅ Flatpak is ready. You can now install apps manually using:"
echo "   flatpak install flathub <app-id>"
