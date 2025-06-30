#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source ./utils.sh

programs=(
  atuin
  bat
  bottom
  chezmoi
  clang
  direnv
  eza
  fd
  fish
  fzf
  git
  git-delta
  github-cli
  jq
  just
  lazydocker
  lazygit
  llvm
  mariadb-libs
  mise
  neovim
  nushell
  ollama
  # podman
  postgresql-libs
  ripgrep
  starship
  tealdeer
  tmux
  trash-cli
  uv
  vim
  yazi
  zellij
  zoxide
  zsh
)

# Call the install_programs function and pass the tools list
install_programs "${programs[@]}"
