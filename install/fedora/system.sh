#!/usr/bin/env bash

set -euo pipefail

# https://rpmfusion.org/Howto/Multimedia

# Update the system
echo "Updating the system..."
sudo dnf upgrade -y

# Enable RPM Fusion repositories for Fedora
echo "Enabling RPM Fusion repositories for Fedora"
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Multimedia codecs
echo "Installing multimedia codecs"
sudo dnf install -y libavcodec-freeworld

# Switch to full ffmpeg
echo "Switching to full ffmpeg"
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

# Install additional codecs
echo "Installing additional codecs"
sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Install Hardware codecs w/ AMD (mesa)
echo "Installing AMD hardware codecs"
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

echo "✅ Installation complete."

