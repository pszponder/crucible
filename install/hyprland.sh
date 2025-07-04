#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  hypridle
  hyprland
  hyprland-qtutils
  hyprlock
  hyprpicker
  hyprpolkitagent
  hyprshot
  mako
  nwg-look
  pipewire
  qt5-wayland
  qt6-wayland
  swaybg
  swaync
  udiskie
  waybar
  wofi
  xdg-desktop-portal-gtk
  xdg-desktop-portal-kde
  xdg-desktop-portal-hyprland
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Start Hyprland on first session
# echo "[[ -z \$DISPLAY && \$(tty) == /dev/tty1 ]] && exec Hyprland" >~/.bash_profile
