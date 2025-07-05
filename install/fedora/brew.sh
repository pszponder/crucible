#!/usr/bin/env bash
set -euo pipefail

# Load utility functions if available
source "$HOME/.local/share/crucible/install/_utils.sh" || true

echo "🍺 Checking for Linuxbrew (Homebrew for Linux)..."

# Detect distro
DISTRO="unknown"
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  DISTRO="$ID"
fi

echo "🖥️ Detected Linux distribution: $DISTRO"

# Install required dependencies for Homebrew
install_homebrew_dependencies() {
  echo "📦 Installing Linuxbrew dependencies..."

  case "$DISTRO" in
    ubuntu | debian)
      sudo apt update
      sudo apt install -y build-essential procps curl file git
      ;;
    fedora)
      sudo dnf install -y gcc gcc-c++ make procps-ng curl file git
      ;;
    *)
      echo "❌ Unsupported distro for Homebrew install."
      exit 1
      ;;
  esac
}

# Install Linuxbrew only if not already installed
install_linuxbrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "✅ Homebrew already installed at $(which brew)"
    return
  fi

  install_homebrew_dependencies

  echo "⬇️ Downloading and installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "✅ Homebrew installation complete"
}

# 🧭 Execute
install_linuxbrew

echo "✅ Setup complete. Run 'brew doctor' to verify your installation."
