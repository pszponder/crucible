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
      sudo dnf group install -y development-tools
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

# Temporarily add Homebrew to PATH for the current session
add_homebrew_to_path() {
  # Check if Homebrew is installed in ~/.linuxbrew or /home/linuxbrew/.linuxbrew
  if test -d ~/.linuxbrew; then
    echo "Homebrew found in ~/.linuxbrew"
    eval "$(~/.linuxbrew/bin/brew shellenv)"
  elif test -d /home/linuxbrew/.linuxbrew; then
    echo "Homebrew found in /home/linuxbrew"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "❌ Homebrew not found. Please install Homebrew first."
    exit 1
  fi

  echo "✅ Homebrew temporarily added to PATH for this session."
}

# Add Homebrew initialization to .bashrc for future sessions
add_homebrew_to_bashrc() {
  if ! grep -q "brew shellenv" ~/.bashrc; then
    echo "eval \"\$(brew shellenv)\"" >> ~/.bashrc
    echo "✅ Homebrew initialization added to ~/.bashrc"
  else
    echo "Homebrew is already initialized in ~/.bashrc."
  fi
}

# 🧭 Execute
install_linuxbrew

# Add Homebrew to the PATH temporarily and initialize it
add_homebrew_to_path

# Add Homebrew initialization to .bashrc for future sessions
add_homebrew_to_bashrc

echo "✅ Setup complete. Homebrew is available for the current session. Run 'brew doctor' to verify your installation."

