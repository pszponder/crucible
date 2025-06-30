#!/usr/bin/env bash
set -euo pipefail

# Update the system and install base-devel if not already installed
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel

if ! command -v yay &>/dev/null; then
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd ~
  rm -rf yay-bin
fi
