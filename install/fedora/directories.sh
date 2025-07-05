#!/usr/bin/env bash
set -euo pipefail

echo "📦 Checking for xdg-user-dirs..."

# Install xdg-user-dirs if not already installed
if ! command -v xdg-user-dirs-update &>/dev/null; then
  echo "📦 Installing xdg-user-dirs..."
  sudo dnf install -y xdg-user-dirs
else
  echo "✅ xdg-user-dirs is already installed."
fi

# Force update to regenerate standard user directories like ~/Documents, ~/Downloads, etc.
echo "📁 Running xdg-user-dirs-update with --force..."
xdg-user-dirs-update --force

# Create custom home directory layout
echo "📂 Creating custom home directories..."
mkdir -p "$HOME/repos/github/pszponder"
mkdir -p "$HOME/repos/bitbucket"
mkdir -p "$HOME/repos/gitlab"
mkdir -p "$HOME/sandbox"
mkdir -p "$HOME/courses"
mkdir -p "$HOME/resources"

echo "✅ Done."
