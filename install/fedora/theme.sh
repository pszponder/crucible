#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_* function
source "$HOME/.local/share/crucible/install/_utils.sh"

# List of required programs
programs=(
  papirus-icon-theme      # Papirus icon theme
)

# Choose your package manager function (change as needed)
install_programs_dnf "${programs[@]}"  # or install_programs_apt, _yay, etc.

# Set GTK and GNOME theme preferences
echo "🎨 Applying dark theme settings..."
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Set the Papirus icon theme
echo "🎨 Setting icon theme to Papirus..."
gsettings set org.gnome.desktop.interface icon-theme "Papirus"

echo "✅ Theme and icon configuration complete!"
