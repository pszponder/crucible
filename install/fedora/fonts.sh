#!/usr/bin/env bash

set -euo pipefail

# List of Nerd Fonts to install
NERD_FONTS=(
  "JetBrainsMono"
  "CascadiaCode"
  "ComicShannsMono"
  "Meslo"
  "NerdFontsSymbolsOnly"
)

NERD_FONT_VERSION="3.4.0"
BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}"

FONT_BASE_DIR="${HOME}/.local/share/fonts/NerdFonts"
NOTO_EMOJI_FONT_DIR="${HOME}/.local/share/fonts/NotoEmoji"

# Create font directories
mkdir -p "$FONT_BASE_DIR"
mkdir -p "$NOTO_EMOJI_FONT_DIR"
cd "$FONT_BASE_DIR"

# Install Nerd Fonts
for FONT in "${NERD_FONTS[@]}"; do
  echo "⬇️ Installing ${FONT} Nerd Font..."

  # Download and extract Nerd Fonts
  wget -q "${BASE_URL}/${FONT}.zip" -O "${FONT}.zip" || { echo "Failed to download ${FONT}"; exit 1; }
  unzip -o "${FONT}.zip" -d "${FONT}" || { echo "Failed to unzip ${FONT}"; exit 1; }
  rm "${FONT}.zip"
done

# Install Noto Emoji Fonts
echo "⬇️ Installing Noto Emoji fonts..."

# Correct Noto Emoji download URL for v2.048 release
NOTO_EMOJI_URL="https://github.com/googlefonts/noto-emoji/archive/refs/tags/v2.048.zip"

# Download and unzip Noto Emoji fonts
wget -q "$NOTO_EMOJI_URL" -O "NotoEmoji.zip" || { echo "Failed to download Noto Emoji"; exit 1; }

# Unzip Noto Emoji
unzip -o "NotoEmoji.zip" -d "$NOTO_EMOJI_FONT_DIR" || { echo "Failed to unzip Noto Emoji"; exit 1; }

# Clean up
rm "NotoEmoji.zip"

# Verify if the files were properly extracted
echo "📁 Files in Noto Emoji font directory:"
ls -lh "$NOTO_EMOJI_FONT_DIR"

# Update font cache
echo "🗂 Updating font cache..."
fc-cache -fv "$FONT_BASE_DIR"
fc-cache -fv "$NOTO_EMOJI_FONT_DIR"

echo "✅ All requested fonts, including Noto Emoji, installed successfully."

