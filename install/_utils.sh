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
    flatpak install -y flathub "$app"
  done

  echo "✅ Installation of programs complete (flatpak)!"
}

web2app() {
  # ------------------------
  # 🌐 Create a Web App Launcher
  # Usage: web2app "AppName" "AppURL" "IconURL"
  # ------------------------

  if [ "$#" -ne 3 ]; then
    echo "Usage: web2app <AppName> <AppURL> <IconURL>"
    echo "Example: web2app 'Gmail' 'https://mail.google.com' 'https://example.com/gmail.png'"
    return 1
  fi

  local APP_NAME="$1"
  local APP_URL="$2"
  local ICON_URL="$3"

  local ICON_DIR="$HOME/.local/share/applications/icons"
  local ICON_PATH="${ICON_DIR}/${APP_NAME}.png"
  local DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"

  mkdir -p "$ICON_DIR"

  # Detect the first available browser
  local BROWSER_CMD=""
  local candidates=("brave" "brave-browser" "chrome" "google-chrome" "chromium")
  for browser in "${candidates[@]}"; do
    if command -v "$browser" &>/dev/null; then
      BROWSER_CMD="$browser"
      break
    fi
  done

  if [ -z "$BROWSER_CMD" ]; then
    echo "Error: No supported browser found (brave, chrome, chromium)."
    return 1
  fi

  # Download the icon
  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon from $ICON_URL"
    return 1
  fi

  # Create the .desktop launcher
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=$BROWSER_CMD --new-window --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
Categories=GTK;
MimeType=text/html;text/xml;application/xhtml_xml;
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"
  echo "✅ Created desktop launcher for $APP_NAME using $BROWSER_CMD"
}
