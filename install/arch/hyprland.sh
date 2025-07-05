#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_yay function
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
  # nwg-look
  pipewire
  qt5-waylan
  qt6-wayland
  # In the future, use rofi mainline instead of rofi-wayland as the two will be merged
  rofi-wayland
  rofi-emoji
  swaybg
  swaync
  udiskie
  waybar
  wlogout
  wtype
  xdg-desktop-portal-gtk
  xdg-desktop-portal-kde
  xdg-desktop-portal-hyprland
)

# Call the install_programs_yay function and pass the tools list
install_programs_yay "${programs[@]}"

# Start Hyprland on first session
# echo "[[ -z \$DISPLAY && \$(tty) == /dev/tty1 ]] && exec Hyprland" >~/.bash_profile
