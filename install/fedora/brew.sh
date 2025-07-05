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

# Add Homebrew to PATH if not already added
add_homebrew_to_path() {
  # Define the Homebrew installation path
  BREW_PATH="$HOME/.linuxbrew/bin"
  
  # For macOS installations, add the Homebrew path to the shell profile
  if [[ ! ":$PATH:" == *":$BREW_PATH:"* ]]; then
    echo "🔧 Adding Homebrew to PATH..."

    # Add to the appropriate shell profile (bash or zsh)
    if [[ -n "$BASH_VERSION" ]]; then
      PROFILE="$HOME/.bashrc"  # Use .bashrc for interactive shells
    elif [[ -n "$ZSH_VERSION" ]]; then
      PROFILE="$HOME/.zshrc"
    else
      PROFILE="$HOME/.bashrc"  # Default to .bashrc if the shell is unknown
    fi

    # Append Homebrew to the PATH if not already present
    if ! grep -q "$BREW_PATH" "$PROFILE"; then
      echo "export PATH=\"$BREW_PATH:\$PATH\"" >> "$PROFILE"
      echo "✅ Homebrew added to PATH in $PROFILE"
    else
      echo "Homebrew is already in PATH."
    fi

    # Source the profile to apply the changes immediately
    source "$PROFILE"
    echo "✅ PATH updated. Homebrew is now available."
  else
    echo "Homebrew is already in the PATH."
  fi
}

# 🧭 Execute
install_linuxbrew

# Add Homebrew to the PATH
add_homebrew_to_path

echo "✅ Setup complete. Run 'brew doctor' to verify your installation."

