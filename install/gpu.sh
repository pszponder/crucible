#!/usr/bin/env bash
set -euo pipefail

# Source the utils.sh script to access the install_programs function
source "$HOME/.local/share/crucible/install/_utils.sh"

echo "🎮 GPU Driver Installation for Arch Linux + Hyprland"

# Prompt for GPU type
echo "Which GPU do you want to install drivers for?"
echo "1) Intel"
echo "2) AMD (GCN 1.2 or newer)"
echo "3) NVIDIA"
read -rp "Enter the number [1-3]: " gpu_choice

gpu_drivers=()

case "$gpu_choice" in
  1)
    echo "🟦 Installing Intel GPU drivers..."
    gpu_drivers=(
      mesa                               # Open-source 3D drivers
      vulkan-intel                       # Vulkan driver
      intel-media-driver                 # For VA-API (Gen8+)
      libva-utils                        # Optional: test VA-API
    )
    ;;
  2)
    echo "🟥 Installing AMD GPU drivers (AMDGPU)..."
    gpu_drivers=(
      mesa                               # DRI/3D driver
      xf86-video-amdgpu                  # Xorg driver (needed if you use X occasionally)
      vulkan-radeon                      # Vulkan support
      libva-mesa-driver                  # VA-API support
      mesa-vdpau                         # VDPAU support
      libva-utils                        # Optional: test VA-API
    )
    echo "ℹ️ Make sure your card supports amdgpu. For GCN 1.0/1.1, set kernel param: amdgpu.si_support=1 radeon.si_support=0"
    ;;
  3)
    echo "🟨 Installing NVIDIA drivers (proprietary)..."
    gpu_drivers=(
      nvidia                             # Kernel module
      nvidia-utils                       # User-space utilities (includes Vulkan)
      nvidia-settings                    # GUI settings tool
      libva-nvidia-driver                # Optional: VA-API via NVDEC/NVENC
    )
    echo "⚠️ Ensure modesetting is enabled and you're using a supported compositor in Wayland"
    ;;
  *)
    echo "❌ Invalid selection. Exiting."
    exit 1
    ;;
esac

# Install the chosen drivers
install_programs "${gpu_drivers[@]}"

echo "✅ GPU drivers installed for your selected configuration."
