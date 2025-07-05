#!/usr/bin/env bash
set -euo pipefail

echo "🔤 Installing Nerd Fonts and Noto Color Emoji..."

# Define list of Nerd Fonts to install from https://github.com/ryanoasis/nerd-fonts/releases
NERD_FONTS=(
  CascadiaCode
  JetBrainsMono
)

# Font install directory
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Function to install a Nerd Font from the official GitHub release
install_nerd_font() {
  local font_name="$1"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"

  echo "⬇️ Downloading ${font_name} Nerd Font..."
  curl -fLo "${font_name}.zip" "$url"

  echo "📦 Extracting ${font_name} to $FONT_DIR..."
  unzip -oq "${font_name}.zip" -d "$FONT_DIR"
  rm -f "${font_name}.zip"
}

# Install all defined Nerd Fonts
for font in "${NERD_FONTS[@]}"; do
  install_nerd_font "$font"
done

# Install Noto Color Emoji from the latest Google Fonts release
echo "⬇️ Downloading Noto Color Emoji..."
EMOJI_URL="$(curl -sL https://api.github.com/repos/googlefonts/noto-emoji/releases/latest \
  | grep browser_download_url \
  | grep -i '\.zip' \
  | head -n1 \
  | cut -d '"' -f4)"

curl -fLo noto-emoji.zip "$EMOJI_URL"
echo "📦 Extracting Noto Color Emoji..."
unzip -oq noto-emoji.zip -d "$FONT_DIR"
rm -f noto-emoji.zip

# Refresh font cache
echo "🔃 Refreshing font cache..."
fc-cache -fv "$FONT_DIR"

echo "✅ Fonts installed successfully in $FONT_DIR"
