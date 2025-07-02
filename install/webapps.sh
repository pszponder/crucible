#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source $HOME/.local/share/crucible/install/_utils.sh

# Search for icons here: https://dashboardicons.com/
# Then, select the PNG version and copy the URL

web2app "Google Photos" https://photos.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-photos.png
web2app "Google Contacts" https://contacts.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-contacts.png
web2app "ChatGPT" https://chatgpt.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png
web2app "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
web2app "YouTube Music" https://music.youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube-music.png
web2app "GitHub" https://github.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png
