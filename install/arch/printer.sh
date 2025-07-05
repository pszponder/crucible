#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_yay function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  cups
  cups-pdf
  cups-filters
  system-config-printer
)

# Call the install_programs_yay function and pass the tools list
install_programs_yay "${programs[@]}"

sudo systemctl enable --now cups.service