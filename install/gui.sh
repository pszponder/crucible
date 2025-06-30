#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source ./utils.sh

programs=(
  brave-bin
  chromium
  discord
  evince
  firefox
  flameshot
  gimp
  ghostty
  gnome-disk-utility
  gnome-calculator
  imagemagick
  imv
  libreoffice
  nautilus
  obsidian
  sushi
  visual-studio-code-bin
  vlc
  zed
  zoom
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"
