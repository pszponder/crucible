#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs_yay function
source $HOME/.local/share/crucible/install/_utils.sh

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
  pacman-contrib
  postgresql-libs
  ripgrep
  starship
  tealdeer
  tmux
  topgrade
  trash-cli
  uv
  vim
  yazi
  zellij
  zoxide
  zsh
)

# Call the install_programs_yay function and pass the tools list
install_programs_yay "${programs[@]}"
