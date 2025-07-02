#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  hyprland
  hyprshot
  hyprpicker
  hyprlock
  hypridle
  hyprpolkitagent
  hyprland-qtutils
  wofi
  waybar
  mako
  swaybg
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Start Hyprland on first session
echo "[[ -z \$DISPLAY && \$(tty) == /dev/tty1 ]] && exec Hyprland" >~/.bash_profile
