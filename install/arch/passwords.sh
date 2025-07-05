#!/usr/bin/env bash
set -euo pipefail

# Check if npm is installed
if ! command -v npm &> /dev/null; then
  echo "❌ npm is not installed. Installing npm using mise..."

  # Check if mise is installed
  if ! command -v mise &> /dev/null; then
    echo "❌ mise is not installed. Please install mise first."
    exit 1
  fi

  # Use mise to install Node.js (which includes npm)
  echo "🔽 Installing Node.js (npm included) using mise..."
  mise use -g node
else
  echo "✅ npm is already installed."
fi

# Install Bitwarden CLI globally
echo "🔽 Installing Bitwarden CLI..."
npm install -g @bitwarden/cli

# Verify installation
if command -v bw &> /dev/null; then
  echo "✅ Bitwarden CLI successfully installed!"
  bw --version
else
  echo "❌ Bitwarden CLI installation failed."
  exit 1
fi
