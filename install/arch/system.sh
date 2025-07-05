#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

programs=(
  btop
  chezmoi
  curl
  fastfetch
  fzf
  inetutils
  less
  make
  man
  plocate
  stow
  unzip
  wget
  whois
  wl-clipboard
  wl-clip-persist
  zip
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"

# Login directly as user, rely on disk encryption + hyprlock for security
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF