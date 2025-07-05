#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob  # allow globs that match nothing to expand to nothing

# Source the utils.sh script to access the install_programs_yay function
source "$HOME/.local/share/crucible/install/_utils.sh"

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

# Install desktop-related tools
install_programs_yay "${programs[@]}"

# Copy and sync icon files (only if they exist)
ICON_SRC=("$HOME/.local/share/crucible/assets/icons/"*.png)
ICON_DEST="$HOME/.local/share/icons/hicolor/48x48/apps/"
mkdir -p "$ICON_DEST"
if (( ${#ICON_SRC[@]} )); then
  cp "${ICON_SRC[@]}" "$ICON_DEST"
fi
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true

# Copy .desktop declarations (only if they exist)
DESKTOP_SRC=("$HOME/.local/share/crucible/apps/"*.desktop)
DESKTOP_DEST="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DEST"
if (( ${#DESKTOP_SRC[@]} )); then
  cp "${DESKTOP_SRC[@]}" "$DESKTOP_DEST"
fi
update-desktop-database "$DESKTOP_DEST" || true
