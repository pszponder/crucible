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

# Function to detect and setup machine based on OS
setup_machine() {
  # Ask the user if they want to set up the machine at all
  read -rp "$(echo -e "${YELLOW}❓ Would you like to set up your machine? (y/N): ${NC}")" setup_machine_answer
  case "$setup_machine_answer" in
    [yY][eE][sS] | [yY])
      ;;
    *)
      print_status "$YELLOW" "⏭️  Machine setup skipped."
      return
      ;;
  esac

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

    # Ask the user if they want to set up a server or a workstation
    echo
    read -rp "$(echo -e "${YELLOW}❓ Do you want to set up a server or a workstation? [s/w] (default: server): ${NC}")" machine_type
    machine_type="${machine_type,,}"
    if [[ "$machine_type" == "w" || "$machine_type" == "workstation" ]]; then
      machine_type="workstation"
    else
      machine_type="server"
    fi

    # Directly execute the correct setup function
    print_status "$BLUE" "⚙️  Starting $NAME $machine_type setup..."
    case "$ID" in
      arch) setup_arch "$machine_type" ;;
      debian|ubuntu) setup_debian "$machine_type" ;;
      fedora) setup_fedora "$machine_type" ;;
    esac
  else
    print_status "$RED" "❌ Unable to detect OS. This script relies on /etc/os-release."
    exit 1
  fi
}

# Example of Arch setup
setup_arch() {
  local machine_type="$1"
  print_status "$GREEN" "💻 Setting up Arch $machine_type..."

  # Ensure git is installed
  pacman -Q git &>/dev/null || sudo pacman -Sy --noconfirm --needed git

  echo -e "\nCloning Crucible..."
  rm -rf $HOME/.local/share/crucible/
  git clone https://github.com/pszponder/crucible.git $HOME/.local/share/crucible >/dev/null

  echo -e "\n $machine_type installation starting..."
  SCRIPTS_DIR="$HOME/.local/share/crucible/install"

  # Common scripts for both server and workstation
  $SCRIPTS_DIR/arch/yay.sh
  $SCRIPTS_DIR/arch/system.sh
  $SCRIPTS_DIR/arch/gpu.sh
  $SCRIPTS_DIR/arch/fonts.sh
  $SCRIPTS_DIR/arch/cli.sh
  $SCRIPTS_DIR/arch/mimetypes.sh
  $SCRIPTS_DIR/arch/directories.sh
  $SCRIPTS_DIR/common/ai.sh
  # $SCRIPTS_DIR/arch/docker.sh

  if [[ "$machine_type" == "server" ]]; then
    $SCRIPTS_DIR/arch/docker.sh
  fi

  if [[ "$machine_type" == "workstation" ]]; then
    # $SCRIPTS_DIR/arch/hyprland.sh
    # $SCRIPTS_DIR/arch/power.sh
    $SCRIPTS_DIR/arch/bluetooth.sh
    $SCRIPTS_DIR/arch/printer.sh
    $SCRIPTS_DIR/arch/gui.sh
    $SCRIPTS_DIR/arch/flatpak.sh
    $SCRIPTS_DIR/arch/webapps.sh
    $SCRIPTS_DIR/arch/desktop.sh
    $SCRIPTS_DIR/arch/theme.sh
    $SCRIPTS_DIR/arch/passwords.sh
    # $SCRIPTS_DIR/arch/docker_desktop.sh
    $SCRIPTS_DIR/arch/docker.sh
  fi

  # Ensure locate is up to date now that everything has been installed
  sudo updatedb
}

# Example of Debian/Ubuntu setup
setup_debian() {
  local machine_type="$1"
  print_status "$GREEN" "💻 Setting up Debian/Ubuntu $machine_type..."

  # Ensure git is installed
  if ! command -v git &> /dev/null; then
    print_status "$YELLOW" "🔄 git not found. Installing..."
    sudo apt update && sudo apt install -y git
  fi

  echo -e "\nCloning Crucible..."
  rm -rf $HOME/.local/share/crucible/
  git clone https://github.com/pszponder/crucible.git $HOME/.local/share/crucible >/dev/null

  echo -e "\n $machine_type installation starting..."
  SCRIPTS_DIR="$HOME/.local/share/crucible/install"

  # Common scripts for both server and workstation
  # $SCRIPTS_DIR/debian/system.sh
  # $SCRIPTS_DIR/debian/directories.sh
  # $SCRIPTS_DIR/debian/flatpak.sh
  # $SCRIPTS_DIR/debian/brew.sh
  # $SCRIPTS_DIR/debian/cli.sh
  # $SCRIPTS_DIR/common/ai.sh

  if [[ "$machine_type" == "server" ]]; then
    $SCRIPTS_DIR/debian/docker.sh
  fi

  if [[ "$machine_type" == "workstation" ]]; then
    # $SCRIPTS_DIR/debian/docker_desktop.sh
    $SCRIPTS_DIR/debian/docker.sh
  fi
}

# Example of Fedora setup
setup_fedora() {
  local machine_type="$1"
  print_status "$GREEN" "💻 Setting up Fedora $machine_type..."

  # Ensure git is installed
  rpm -q git &>/dev/null || sudo dnf install -y git

  echo -e "\nCloning Crucible..."
  rm -rf $HOME/.local/share/crucible/
  git clone https://github.com/pszponder/crucible.git $HOME/.local/share/crucible >/dev/null

  echo -e "\n $machine_type installation starting..."
  SCRIPTS_DIR="$HOME/.local/share/crucible/install"

  # Common scripts for both server and workstation
  $SCRIPTS_DIR/fedora/system.sh
  $SCRIPTS_DIR/fedora/directories.sh
  $SCRIPTS_DIR/fedora/flatpak.sh
  $SCRIPTS_DIR/fedora/brew.sh
  $SCRIPTS_DIR/fedora/cli.sh
  $SCRIPTS_DIR/common/ai.sh

  if [[ "$machine_type" == "server" ]]; then
    $SCRIPTS_DIR/fedora/docker.sh
  fi

  if [[ "$machine_type" == "workstation" ]]; then
    $SCRIPTS_DIR/fedora/gui.sh
    $SCRIPTS_DIR/fedora/fonts.sh
    $SCRIPTS_DIR/fedora/theme.sh
    # $SCRIPTS_DIR/fedora/docker_desktop.sh
    $SCRIPTS_DIR/fedora/docker.sh
  fi
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

# Function to prompt user before setting up dotfiles (skips if already initialized)
prompt_dotfile_setup() {
  local chezmoi_repo_dir="$HOME/.local/share/chezmoi"

  if [ -d "$chezmoi_repo_dir/.git" ]; then
    print_status "$GREEN" "✅ Dotfiles already initialized at $chezmoi_repo_dir. Skipping setup."
    return
  fi

  echo
  read -rp "$(echo -e "${YELLOW}❓ Would you like to set up your dotfiles using chezmoi? (y/N): ${NC}")" dotfiles_answer
  case "$dotfiles_answer" in
    [yY][eE][sS] | [yY])
      print_status "$BLUE" "📂 Proceeding with dotfile setup..."
      setup_dotfiles
      ;;
    *)
      print_status "$YELLOW" "⏭️  Dotfile setup skipped."
      ;;
  esac
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

# Function to clean up this script's directory
cleanup_self_directory() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo
  read -rp "$(echo -e "${YELLOW}🧹 Do you want to delete this script and its directory at ${SCRIPT_DIR}? (y/N): ${NC}")" delete_self

  case "$delete_self" in
    [yY][eE][sS] | [yY])
      print_status "$RED" "🧨 Deleting directory: $SCRIPT_DIR"
      cd ~  # Change directory to avoid deleting the current working directory
      rm -rf "$SCRIPT_DIR"
      ;;
    *)
      print_status "$YELLOW" "⏭️  Cleanup skipped."
      ;;
  esac
}

# ==========
# -- Main --
# ==========

# Clear screen and show logo
clear
print_logo

setup_machine
prompt_dotfile_setup

cleanup_self_directory