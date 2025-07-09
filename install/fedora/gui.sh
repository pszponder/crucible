#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_yay function
source "$HOME/.local/share/crucible/install/_utils.sh"

# programs_dnf=()

# List of Flatpak app IDs to install
programs_flatpak=(
  com.github.tchx84.Flatseal
  # com.visualstudio.code
  # org.mozilla.firefox
  org.chromium.Chromium
  app.zen_browser.zen
  com.mattjakeman.ExtensionManager
  org.gnome.Extensions
  com.jeffser.Alpaca
  it.mijorus.gearlever
  it.mijorus.collector
  it.mijorus.smile
  com.jeffser.Pigment
  io.podman_desktop.PodmanDesktop
  com.discordapp.Discord
  org.flameshot.Flameshot
  org.gimp.GIMP
  md.obsidian.Obsidian
  org.videolan.VLC
  # org.libreoffice.LibreOffice
  com.bitwarden.desktop
)

# install_programs_dnf "${programs_dnf[@]}"
install_programs_flatpak "${programs_flatpak[@]}"

# Install Brave Browser
curl -fsS https://dl.brave.com/install.sh | sh

# Install Zed editor
curl -f https://zed.dev/install.sh | sh

# Install VSCode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
dnf check-update
sudo dnf install -y code # or code-insiders

# Install Warp terminal
echo "📥 Downloading Warp RPM..."
TMP_WARP_RPM="$(mktemp --suffix=.rpm)"
curl -fsSL "https://app.warp.dev/get_warp?package=rpm" -o "$TMP_WARP_RPM"
echo "📦 Installing Warp..."
sudo dnf install -y "$TMP_WARP_RPM"
rm -f "$TMP_WARP_RPM"
echo "✅ Warp installation completed!"

# Install Google Chrome (Stable) via official RPM
echo "🌐 Installing Google Chrome..."
TMP_CHROME_RPM="$(mktemp --suffix=.rpm)"
curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -o "$TMP_CHROME_RPM"
sudo dnf install -y "$TMP_CHROME_RPM"
rm -f "$TMP_CHROME_RPM"
echo "✅ Google Chrome installation completed!"

