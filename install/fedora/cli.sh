#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_yay function
source $HOME/.local/share/crucible/install/_utils.sh

programs_dnf=(
  fish
  zsh
  wl-clipboard
  wl-clip-persist
)

programs_brew=(
  atuin
  bat
  bottom
  btop
  chezmoi
  clang
  curl
  direnv
  eza
  fastfetch
  fd
  fzf
  git
  git-delta
  github-cli
  jq
  just
  lazydocker
  lazygit
  llvm
  make
  mise
  neovim
  nushell
  ollama
  # podman
  ripgrep
  starship
  tealdeer
  tmux
  trash-cli
  unzip
  uv
  vim
  wget
  yazi
  zellij
  zip
  zoxide
)

install_programs_dnf "${programs_dnf[@]}"
install_programs_brew "${programs_brew[@]}"

# Install nushell
echo "[gemfury-nushell]
name=Gemfury Nushell Repo
baseurl=https://yum.fury.io/nushell/
enabled=1
gpgcheck=0
gpgkey=https://yum.fury.io/nushell/gpg.key" | sudo tee /etc/yum.repos.d/fury-nushell.repo
sudo dnf install -y nushell