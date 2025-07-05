#!/usr/bin/env bash
set -euo pipefail

# Function to install programs using yay
install_programs_yay() {
  local program_list=("$@")  # Accept a list of programs passed as arguments

  # Format the list of programs for better readability
  echo "🔄 Installing the following programs: ${program_list[*]}"

  # Install tools using yay
  yay -S --noconfirm --needed "${program_list[@]}"

  # Confirm installation
  echo "✅ Installation of programs complete!"
}

# Function to install programs using dnf
install_programs_dnf() {
  local program_list=("$@")  # Accept a list of programs passed as arguments

  echo "🔄 Installing the following programs with dnf: ${program_list[*]}"

  sudo dnf install -y "${program_list[@]}"

  echo "✅ Installation of programs complete (dnf)!"
}

# Function to install programs using apt
install_programs_apt() {
  local program_list=("$@")  # Accept a list of programs passed as arguments

  echo "🔄 Installing the following programs with apt: ${program_list[*]}"

  sudo apt update
  sudo apt install -y "${program_list[@]}"

  echo "✅ Installation of programs complete (apt)!"
}

# Function to install programs using Homebrew
install_programs_brew() {
  local program_list=("$@")  # Accept a list of programs passed as arguments

  echo "🔄 Installing the following programs with Homebrew: ${program_list[*]}"

  brew install "${program_list[@]}"

  echo "✅ Installation of programs complete (brew)!"
}


# Function to install programs using Flatpak
install_programs_flatpak() {
  local program_list=("$@")  # Accept a list of programs passed as arguments

  echo "🔄 Installing the following programs with Flatpak: ${program_list[*]}"

  # Install tools using flatpak
  for app in "${program_list[@]}"; do
    flatpak install -y "$app"
  done

  echo "✅ Installation of programs complete (flatpak)!"
}

# Create a desktop launcher for a web app
web2app() {
  if [ "$#" -ne 3 ]; then
    echo "Usage: web2app <AppName> <AppURL> <IconURL> (IconURL must be in PNG -- use https://dashboardicons.com)"
    return 1
  fi

  local APP_NAME="$1"
  local APP_URL="$2"
  local ICON_URL="$3"
  local ICON_DIR="$HOME/.local/share/applications/icons"
  local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
  local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"

  mkdir -p "$ICON_DIR"

  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon."
    return 1
  fi

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=chromium --new-window --ozone-platform=wayland --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"
}


# Create a desktop launcher for a web app
web2appbrave() {
  if [ "$#" -ne 3 ]; then
    echo "Usage: web2app <AppName> <AppURL> <IconURL> (IconURL must be in PNG -- use https://dashboardicons.com)"
    return 1
  fi

  local APP_NAME="$1"
  local APP_URL="$2"
  local ICON_URL="$3"
  local ICON_DIR="$HOME/.local/share/applications/icons"
  local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
  local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"

  mkdir -p "$ICON_DIR"

  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon."
    return 1
  fi

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=brave --new-window --ozone-platform=wayland --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"
}