# Installing Arch

- Install arch
- Install `hyprland` and `kitty`
    - `sudo pacman -S hyprland kitty --needed`
- You can reference a clean copy of the default `hyprland.conf` [here](https://github.com/hyprwm/Hyprland/tree/main/example)
- If you don't have a display manager like `sddm` or `gdm`, you need to configure auto-login
    - https://wiki.archlinux.org/title/Xinit#Autostart_X_at_login

Add the below to .bashrc or .zshrc
```sh
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec Hyprland
fi
```

List of apps to install
- hyprland
- kitty
- swaync
- pipewire
- xdg-desktop-portal-hyprland
- polkit-gnome
- qt5-wayland
- qt6-wayland
- nwg-look
- swww
- waybar / hyperpanel
- udiskie
- python-pywal16 / matugen-bin
- hypridle
- hyprlock