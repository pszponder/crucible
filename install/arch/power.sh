#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  power-profiles-daemon
  libgudev
  polkit-gobject
  gobject-introspection
  python-gobject
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Enable the power-profiles-daemon service
echo "Enabling power-profiles-daemon service..."
sudo systemctl enable --now power-profiles-daemon.service

# powerprofilesctl set power-saver
# powerprofilesctl set balanced
# powerprofilesctl set performance

# 📝 Set performance profile if on AC, balanced if on battery
if compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
  # ✅ Battery is present (likely a laptop)
  if grep -q "Charging" /sys/class/power_supply/BAT*/status 2>/dev/null; then
    # 🔌 Plugged in and charging
    powerprofilesctl set performance
  else
    # 🔋 Running on battery
    powerprofilesctl set balanced
  fi
else
  # ⚡️ No battery detected (likely a desktop)
  powerprofilesctl set performance
fi
