#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  ttf-font-awesome
  ttf-cascadia-code-nerd
  ttf-jetbrains-mono-nerd
  noto-fonts
  noto-fonts-emoji
  noto-fonts-cjk
  noto-fonts-extra
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Update the font cache
fc-cache -fv
