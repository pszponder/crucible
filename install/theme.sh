#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source ./_utils.sh

programs=(
  # Use dark mode for QT apps too (like VLC and kdenlive)
  kvantum-qt5
  gnome-themes-extra
  papirus-icon-theme
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Prefer dark mode everything
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Set the default icon theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
