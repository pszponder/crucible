#!/usr/bin/env bash
set -euo pipefail

# Update the system
sudo dnf update -y && sudo dnf upgrade -y

# Enable RPM Fusion repositories for Fedora
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install Terra repository for Fedora
dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release