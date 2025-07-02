#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  brightnessctl
  clipse
  desktop-file-utils
  fcitx5
  fcitx5-gtk
  fcitx5-qt
  fcitx5-configtool
  playerctl
  pamixer
  pavucontrol
  wireplumber
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Copy and sync icon files
mkdir -p $HOME/.local/share/icons/hicolor/48x48/apps/
cp $HOME/.local/share/crucible/assets/icons/*.png $HOME/.local/share/icons/hicolor/48x48/apps/
gtk-update-icon-cache $HOME/.local/share/icons/hicolor &>/dev/null

# Copy .desktop declarations
mkdir -p $HOME/.local/share/applications
cp $HOME/.local/share/crucible/apps/*.desktop $HOME/.local/share/applications/
update-desktop-database $HOME/.local/share/applications