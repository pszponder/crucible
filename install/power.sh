#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  power-profiles-daemon
  python-gobject
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Ensure python is installed (via mise)

# Setting the performance profile can make a big difference. By default, most systems seem to start in balanced mode,
# even if they're not running off a battery. So let's make sure that's changed to performance.
if ls /sys/class/power_supply/BAT* &>/dev/null; then
  # This computer runs on a battery
  esctl set balanced
else
  # This computer runs on power outlet
  powerprofilesctl set performance
fi