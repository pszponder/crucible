#!/usr/bin/env bash

# Exit on any error
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${NC}"
}

print_logo() {
    cat << "EOF"
    ______                _ __    __
   / ____/______  _______(_) /_  / /__
  / /   / ___/ / / / ___/ / __ \/ / _ \
 / /___/ /  / /_/ / /__/ / /_/ / /  __/
 \____/_/   \__,_/\___/_/_.___/_/\___/   System Crafting Tool

EOF
}

# Function to detect and setup workstation based on OS
setup_workstation() {
  # Check for OS type using /etc/os-release
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    case "$ID" in
      arch)
        print_status "$BLUE" "🖥️  Arch Linux detected."
        ;;
      debian|ubuntu)
        print_status "$BLUE" "🖥️  Debian/Ubuntu detected."
        ;;
      fedora)
        print_status "$BLUE" "🖥️  Fedora detected."
        ;;
      *)
        print_status "$RED" "❌ Unsupported OS: $ID. This setup script supports Arch, Debian/Ubuntu, and Fedora only."
        exit 1
        ;;
    esac

    # Ask the user if they want to set up their workstation
    read -rp "$(echo -e "${YELLOW}❓ Would you like to set up your $NAME workstation? (y/N): ${NC}")" setup_answer
    case "$setup_answer" in
      [yY][eE][sS] | [yY])
        print_status "$BLUE" "⚙️  Starting $NAME workstation setup..."
        # Call respective setup function based on the OS
        case "$ID" in
          arch) setup_arch ;;
          debian|ubuntu) setup_debian ;;
          fedora) setup_fedora ;;
        esac
        ;;
      *)
        print_status "$YELLOW" "⏭️  $NAME workstation setup skipped."
        ;;
    esac
  else
    print_status "$RED" "❌ Unable to detect OS. This script relies on /etc/os-release."
    exit 1
  fi
}

# Example of Arch setup
setup_arch() {
  print_status "$GREEN" "💻 Setting up Arch workstation..."

  # Ensure git is installed
  pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git

  echo -e "\nCloning Crucible..."
  rm -rf $HOME/.local/share/crucible/
  git clone https://github.com/pszponder/crucible.git $HOME/.local/share/crucible >/dev/null

  echo -e "\n Workstation installation starting..."
  SCRIPTS_DIR="$HOME/.local/share/crucible/install"
  $SCRIPTS_DIR/yay.sh
  $SCRIPTS_DIR/system.sh
  $SCRIPTS_DIR/fonts.sh
  $SCRIPTS_DIR/hyprland.sh
  $SCRIPTS_DIR/power.sh
  $SCRIPTS_DIR/bluetooth.sh
  $SCRIPTS_DIR/printer.sh
  $SCRIPTS_DIR/docker.sh
  $SCRIPTS_DIR/cli.sh
  $SCRIPTS_DIR/gui.sh
  $SCRIPTS_DIR/flatpak.sh
  $SCRIPTS_DIR/webapps.sh
  $SCRIPTS_DIR/desktop.sh
  $SCRIPTS_DIR/mimetypes.sh
  $SCRIPTS_DIR/theme.sh
  $SCRIPTS_DIR/passwords.sh
  $SCRIPTS_DIR/directories.sh

  # Ensure locate is up to date now that everything has been installed
  sudo updatedb
}

# Example of Debian/Ubuntu setup
setup_debian() {
  print_status "$GREEN" "💻 Setting up Debian/Ubuntu workstation..."
  # Place specific Debian/Ubuntu setup steps here
}

# Example of Fedora setup
setup_fedora() {
  print_status "$GREEN" "💻 Setting up Fedora workstation..."
  # Place specific Fedora setup steps here
}

# Function to check if chezmoi is installed
install_chezmoi_if_needed() {
  if ! command -v chezmoi &> /dev/null; then
    print_status "$YELLOW" "🔄 chezmoi not found. Installing..."
    sh -c "$(curl -fsLS get.chezmoi.io)"
    print_status "$GREEN" "✅ chezmoi installed successfully!"
  else
    print_status "$GREEN" "✅ chezmoi is already installed."
  fi
}

# Function to switch chezmoi repo to SSH
switch_chezmoi_to_ssh() {
  local chezmoi_repo_dir="$HOME/.local/share/chezmoi"
  local ssh_url="git@github.com:pszponder/dotfiles.git"
  local https_url="https://github.com/pszponder/dotfiles.git"

  if [ -d "$chezmoi_repo_dir/.git" ]; then
    cd "$chezmoi_repo_dir"

    local current_url
    current_url=$(git remote get-url origin)

    if [[ "$current_url" == "$https_url" ]]; then
      print_status "$YELLOW" "🔄 Switching chezmoi dotfiles repo from HTTPS to SSH..."
      git remote set-url origin "$ssh_url"
      print_status "$GREEN" "✅ Remote URL updated to SSH: $ssh_url"
    else
      print_status "$GREEN" "✅ chezmoi remote is already using SSH or a custom URL."
    fi
  else
    print_status "$RED" "❌ chezmoi git directory not found. Has it been initialized?"
    exit 1
  fi
}

# Main logic to setup dotfiles and chezmoi
setup_dotfiles() {
  install_chezmoi_if_needed

  print_status "$BLUE" "🚀 Initializing chezmoi with HTTPS..."
  chezmoi init --apply pszponder

  switch_chezmoi_to_ssh

  print_status "$GREEN" "🎉 chezmoi initialization and SSH switch complete!"

  # Reminder to set up SSH keys
  print_status "$YELLOW" "⚠️ Remember to set up your SSH keys if you haven't already!"
}

# Function to prompt the user if they want to restart the machine
prompt_user_restart() {
  echo
  read -rp "$(echo -e "${YELLOW}⚠️  Would you like to restart the machine now to ensure all changes are applied? (y/N): ${NC}")" restart_answer
  case "$restart_answer" in
    [yY][eE][sS] | [yY])
      print_status "$BLUE" "🔁 Restarting the system..."
      sudo reboot
      ;;
    *)
      print_status "$YELLOW" "⏭️  Restart skipped. You may want to restart later to ensure all changes are applied."
      ;;
  esac
}

# ==========
# -- Main --
# ==========

# Clear screen and show logo
clear
print_logo

setup_workstation
setup_dotfiles
prompt_user_restart