#!/usr/bin/env bash
set -euo pipefail

# Install bluetooth controls
yay -S --noconfirm --needed blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
