#!/bin/bash

# Docker Desktop Installation Script for Ubuntu/Debian
# This script automates the installation and configuration of Docker Desktop on Ubuntu/Debian workstations
# Based on official Docker documentation:
# - https://docs.docker.com/desktop/setup/install/linux/ubuntu/
# - https://docs.docker.com/desktop/setup/install/linux/debian/
#
# Usage: ./install_docker_desktop_ubuntu_debian.sh [OPTIONS]
# Options:
#   --manual-setup    Skip automated post-installation setup
#   --help           Show this help message

set -e  # Exit on any error

# Default configuration
SKIP_AUTO_SETUP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --manual-setup)
            SKIP_AUTO_SETUP=true
            shift
            ;;
        --help)
            echo "Docker Desktop Installation Script for Ubuntu/Debian"
            echo
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --manual-setup    Skip automated post-installation setup"
            echo "  --help           Show this help message"
            echo
            echo "This script will:"
            echo "  - Check system requirements"
            echo "  - Check for existing Docker installations"
            echo "  - Install prerequisites"
            echo "  - Download and install Docker Desktop"
            echo "  - Configure Docker Desktop (unless --manual-setup is used)"
            echo "  - Start Docker Desktop and test installation"
            echo
            echo "Supported systems:"
            echo "  - Ubuntu 22.04, 24.04, or latest non-LTS"
            echo "  - Debian 12 (64-bit)"
            echo
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        log_info "Please run as a regular user. The script will use sudo when needed."
        exit 1
    fi
}

# Function to detect OS and version
detect_os_version() {
    log_info "Detecting operating system..."

    if ! command -v apt-get &> /dev/null; then
        log_error "This script is designed for Ubuntu/Debian. APT package manager not found."
        exit 1
    fi

    # Detect OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION_ID"
        OS_ID="$ID"

        log_info "Detected OS: $OS_NAME"
        log_info "Version: $VERSION_ID"
    else
        log_error "Cannot detect operating system"
        exit 1
    fi

    # Check if it's Ubuntu or Debian
    case "$OS_ID" in
        ubuntu)
            log_success "Ubuntu detected"
            # Check supported versions
            case "$OS_VERSION" in
                "22.04"|"24.04")
                    log_success "Supported Ubuntu version: $OS_VERSION"
                    ;;
                *)
                    log_warning "Docker Desktop officially supports Ubuntu 22.04, 24.04, or latest non-LTS. You're running $OS_VERSION."
                    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        exit 1
                    fi
                    ;;
            esac
            ;;
        debian)
            log_success "Debian detected"
            # Check supported versions
            case "$OS_VERSION" in
                "12")
                    log_success "Supported Debian version: $OS_VERSION"
                    ;;
                *)
                    log_warning "Docker Desktop officially supports Debian 12. You're running Debian $OS_VERSION."
                    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        exit 1
                    fi
                    ;;
            esac
            ;;
        *)
            log_error "Unsupported operating system: $OS_NAME"
            log_info "This script supports Ubuntu and Debian only."
            exit 1
            ;;
    esac
}

# Function to check system requirements
check_system_requirements() {
    log_info "Checking system requirements..."

    # Check if 64-bit
    ARCH=$(uname -m)
    if [[ $ARCH != "x86_64" ]]; then
        log_error "Docker Desktop requires a 64-bit system. Detected: $ARCH"
        exit 1
    fi

    # Check available memory (minimum 4GB recommended)
    MEMORY_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEMORY_GB=$((MEMORY_KB / 1024 / 1024))

    if [[ $MEMORY_GB -lt 4 ]]; then
        log_warning "System has ${MEMORY_GB}GB RAM. Docker Desktop recommends at least 4GB."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "System has ${MEMORY_GB}GB RAM - meets requirements"
    fi
}

# Function to detect desktop environment
detect_desktop_environment() {
    log_info "Detecting desktop environment..."

    if [[ $XDG_CURRENT_DESKTOP == *"GNOME"* ]]; then
        DESKTOP_ENV="GNOME"
        log_info "GNOME desktop environment detected"
    elif [[ $XDG_CURRENT_DESKTOP == *"KDE"* ]]; then
        DESKTOP_ENV="KDE"
        log_info "KDE desktop environment detected"
    else
        DESKTOP_ENV="OTHER"
        log_info "Desktop environment: $XDG_CURRENT_DESKTOP"
    fi
}

# Function to check for existing Docker installations
check_existing_docker() {
    log_info "Checking for existing Docker installations..."

    local has_docker_desktop=false
    local has_docker_engine=false
    local has_docker_cli=false

    # Check for Docker Desktop
    if [[ -x "/opt/docker-desktop/bin/docker-desktop" ]]; then
        has_docker_desktop=true
        log_warning "Docker Desktop is already installed at /opt/docker-desktop"
    fi

    # Check for Docker Engine service
    if systemctl is-active docker &>/dev/null || systemctl is-enabled docker &>/dev/null; then
        has_docker_engine=true
        log_warning "Docker Engine service is installed and/or running"
    fi

    # Check for Docker CLI
    if command -v docker &>/dev/null; then
        has_docker_cli=true
        EXISTING_DOCKER_VERSION=$(docker --version 2>/dev/null || echo "Unknown version")
        log_warning "Docker CLI is already available: $EXISTING_DOCKER_VERSION"
    fi

    # Check for Docker packages
    local docker_packages=$(dpkg -l | grep -E '^ii.*docker' | awk '{print $2}' | head -5)
    if [[ -n "$docker_packages" ]]; then
        log_warning "Found existing Docker packages:"
        echo "$docker_packages" | while read -r package; do
            log_info "  - $package"
        done
    fi

    # If Docker Desktop is already installed, ask if user wants to continue
    if [[ $has_docker_desktop == true ]]; then
        echo
        log_warning "Docker Desktop appears to be already installed."
        read -p "Do you want to continue with the installation anyway? This may reinstall or upgrade Docker Desktop. (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
        return 0
    fi

    # If Docker Engine is running, warn about potential conflicts
    if [[ $has_docker_engine == true ]]; then
        echo
        log_warning "Docker Engine appears to be installed/running."
        log_warning "Docker Desktop includes its own Docker Engine, which may conflict."
        log_info "Docker Desktop will manage Docker contexts to avoid conflicts."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
    fi

    if [[ $has_docker_cli == true ]]; then
        log_info "Existing Docker CLI will be updated by Docker Desktop installation"
    fi

    return 0
}

# Function to install prerequisites
install_prerequisites() {
    log_info "Installing prerequisites..."

    # Update package database
    log_info "Updating package database..."
    sudo apt-get update -y

    # Install required packages
    PACKAGES=("curl" "wget" "ca-certificates" "gnupg" "lsb-release")

    # Install gnome-terminal if not using GNOME
    if [[ $DESKTOP_ENV != "GNOME" ]]; then
        log_info "Installing gnome-terminal (required for non-GNOME environments)..."
        PACKAGES+=("gnome-terminal")
    fi

    for package in "${PACKAGES[@]}"; do
        if ! dpkg -l "$package" &> /dev/null; then
            log_info "Installing $package..."
            sudo apt-get install -y "$package"
        else
            log_success "$package is already installed"
        fi
    done

    # GNOME extensions notice
    if [[ $DESKTOP_ENV == "GNOME" ]]; then
        log_warning "For GNOME users: You may need to install AppIndicator and KStatusNotifierItem extensions"
        log_info "Visit: https://extensions.gnome.org/extension/615/appindicator-support/"
        read -p "Press Enter to continue after installing the extensions (or skip if already installed)..."
    fi
}

# Function to download Docker Desktop
download_docker_desktop() {
    log_info "Downloading Docker Desktop..."

    DOCKER_DESKTOP_URL="https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"
    DOWNLOAD_PATH="/tmp/docker-desktop-amd64.deb"

    # Download Docker Desktop DEB
    if [[ -f "$DOWNLOAD_PATH" ]]; then
        log_info "Docker Desktop DEB already exists, removing old version..."
        rm -f "$DOWNLOAD_PATH"
    fi

    log_info "Downloading from: $DOCKER_DESKTOP_URL"
    if curl -L -o "$DOWNLOAD_PATH" "$DOCKER_DESKTOP_URL"; then
        log_success "Docker Desktop downloaded successfully"
    else
        log_error "Failed to download Docker Desktop"
        exit 1
    fi

    # Verify download
    if [[ -f "$DOWNLOAD_PATH" ]] && [[ -s "$DOWNLOAD_PATH" ]]; then
        FILE_SIZE=$(du -h "$DOWNLOAD_PATH" | cut -f1)
        log_success "Download verified - File size: $FILE_SIZE"
    else
        log_error "Downloaded file is empty or doesn't exist"
        exit 1
    fi
}

# Function to install Docker Desktop
install_docker_desktop() {
    log_info "Installing Docker Desktop..."

    DOWNLOAD_PATH="/tmp/docker-desktop-amd64.deb"

    # Update package database again
    sudo apt-get update

    # Install Docker Desktop - note: this may show a warning about downloaded packages, which is normal
    log_info "Installing Docker Desktop package (you may see a warning about downloaded packages - this is normal)..."
    if sudo apt-get install -y "$DOWNLOAD_PATH"; then
        log_success "Docker Desktop installed successfully"
    else
        log_error "Failed to install Docker Desktop"
        exit 1
    fi

    # Clean up downloaded file
    rm -f "$DOWNLOAD_PATH"
    log_info "Cleaned up downloaded DEB file"
}

# Function to configure Docker Desktop
configure_docker_desktop() {
    log_info "Configuring Docker Desktop..."

    # Add user to docker group if it exists
    if getent group docker > /dev/null 2>&1; then
        log_info "Adding user to docker group..."
        sudo usermod -aG docker "$USER"
        log_success "User added to docker group"
        log_warning "You may need to log out and back in for group changes to take effect"
    fi

    # Enable Docker Desktop service for current user
    log_info "Enabling Docker Desktop service..."
    if systemctl --user enable docker-desktop 2>/dev/null; then
        log_success "Docker Desktop service enabled"
    else
        log_warning "Could not enable Docker Desktop service (this is normal if not logged in via GUI)"
    fi
}

# Function to install GNOME extensions automatically
install_gnome_extensions() {
    if [[ $DESKTOP_ENV == "GNOME" ]]; then
        log_info "Attempting to install GNOME AppIndicator extension..."

        # Check if gnome-extensions command is available
        if command -v gnome-extensions &> /dev/null; then
            # Check if the extension is already installed
            if gnome-extensions list | grep -q "appindicatorsupport@rgcjonas.gmail.com"; then
                log_success "AppIndicator extension is already installed"
                # Enable the extension
                if gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null; then
                    log_success "AppIndicator extension enabled"
                else
                    log_warning "Could not enable AppIndicator extension automatically"
                fi
            else
                log_warning "AppIndicator extension not found. Please install it manually from:"
                log_info "https://extensions.gnome.org/extension/615/appindicator-support/"
            fi
        else
            log_warning "gnome-extensions command not available. Please install AppIndicator extension manually from:"
            log_info "https://extensions.gnome.org/extension/615/appindicator-support/"
        fi
    fi
}

# Function to start Docker Desktop
start_docker_desktop() {
    log_info "Starting Docker Desktop..."

    # Try to start Docker Desktop service
    if systemctl --user start docker-desktop 2>/dev/null; then
        log_success "Docker Desktop service started"

        # Wait a moment for the service to initialize
        log_info "Waiting for Docker Desktop to initialize..."
        sleep 5

        # Check if Docker Desktop is running
        if systemctl --user is-active docker-desktop &>/dev/null; then
            log_success "Docker Desktop is running"
            return 0
        else
            log_warning "Docker Desktop service started but may not be fully initialized"
            return 1
        fi
    else
        log_warning "Could not start Docker Desktop service automatically"
        log_info "You can start it manually with: systemctl --user start docker-desktop"
        return 1
    fi
}

# Function to test Docker installation
test_docker_installation() {
    log_info "Testing Docker installation..."

    # First check if docker command is available
    if ! command -v docker &>/dev/null; then
        log_warning "Docker command not found in PATH"
        return 1
    fi

    # Wait for Docker to be ready (up to 30 seconds)
    local max_attempts=30
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if timeout 5 docker info &>/dev/null; then
            log_success "Docker daemon is ready"
            break
        else
            if [[ $attempt -eq $max_attempts ]]; then
                log_warning "Docker daemon is not ready after $max_attempts seconds"
                log_info "You may need to start Docker Desktop manually and test later"
                return 1
            fi
            log_info "Waiting for Docker daemon to be ready... (attempt $attempt/$max_attempts)"
            sleep 1
            ((attempt++))
        fi
    done

    # Test with hello-world
    log_info "Running hello-world container test..."
    if timeout 30 docker run --rm hello-world &>/dev/null; then
        log_success "Docker hello-world test passed!"
        return 0
    else
        log_warning "Docker hello-world test failed or timed out"
        log_info "This may be normal if Docker Desktop is still starting up"
        log_info "You can test manually later with: docker run hello-world"
        return 1
    fi
}

# Function to create desktop shortcut
create_desktop_shortcut() {
    log_info "Creating desktop shortcut..."

    local desktop_dir="$HOME/Desktop"
    local applications_dir="$HOME/.local/share/applications"

    # Create applications directory if it doesn't exist
    mkdir -p "$applications_dir"

    # Check if Docker Desktop desktop file exists
    if [[ -f "/usr/share/applications/docker-desktop.desktop" ]]; then
        # Copy to user applications directory
        cp "/usr/share/applications/docker-desktop.desktop" "$applications_dir/"
        log_success "Docker Desktop added to applications menu"

        # Create desktop shortcut if Desktop directory exists
        if [[ -d "$desktop_dir" ]]; then
            cp "/usr/share/applications/docker-desktop.desktop" "$desktop_dir/"
            chmod +x "$desktop_dir/docker-desktop.desktop"
            log_success "Docker Desktop shortcut created on desktop"
        fi
    else
        log_warning "Docker Desktop .desktop file not found"
    fi
}

# Function to configure automatic startup
configure_auto_startup() {
    log_info "Configuring Docker Desktop to start automatically..."

    # Enable the systemd user service
    if systemctl --user enable docker-desktop 2>/dev/null; then
        log_success "Docker Desktop configured to start automatically on login"
    else
        log_warning "Could not configure automatic startup"
        log_info "You can enable it manually with: systemctl --user enable docker-desktop"
    fi
}

# Function to perform comprehensive post-installation setup
post_installation_setup() {
    log_info "Performing post-installation setup..."

    # Install GNOME extensions if needed
    install_gnome_extensions

    # Create desktop shortcuts
    create_desktop_shortcut

    # Configure automatic startup
    configure_auto_startup

    # Start Docker Desktop
    if start_docker_desktop; then
        # Test Docker installation
        test_docker_installation
    else
        log_info "Skipping Docker test as Docker Desktop is not running"
    fi
}

# Function to verify installation
verify_installation() {
    log_info "Verifying installation..."

    # Check if Docker Desktop binary exists
    if [[ -x "/opt/docker-desktop/bin/docker-desktop" ]]; then
        log_success "Docker Desktop binary found at /opt/docker-desktop"
    else
        log_error "Docker Desktop binary not found"
        return 1
    fi

    # Check if Docker CLI is available
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null || echo "Not available")
        log_success "Docker CLI available: $DOCKER_VERSION"
    else
        log_warning "Docker CLI not found in PATH"
    fi

    # Check if Docker Compose is available
    if command -v docker-compose &> /dev/null || docker compose version &>/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "Not available")
        log_success "Docker Compose available: $COMPOSE_VERSION"
    else
        log_warning "Docker Compose not found in PATH"
    fi
}

# Function to display post-installation information
show_post_install_info() {
    echo
    log_success "Docker Desktop installation and configuration completed!"
    echo
    echo "What was automated:"
    echo "✓ Docker Desktop installed and configured"
    echo "✓ User added to docker group"
    echo "✓ Docker Desktop service enabled for auto-start"
    echo "✓ Desktop shortcuts created"

    if [[ $DESKTOP_ENV == "GNOME" ]]; then
        echo "✓ GNOME AppIndicator extension status checked"
    fi

    echo
    echo "Post-installation status:"

    # Check if Docker Desktop is running
    if systemctl --user is-active docker-desktop &>/dev/null; then
        echo "✓ Docker Desktop is currently running"
    else
        echo "⚠ Docker Desktop is not currently running"
        echo "  Start it with: systemctl --user start docker-desktop"
        echo "  Or from Applications menu: Search for 'Docker Desktop'"
    fi

    # Check Docker CLI
    if command -v docker &> /dev/null; then
        echo "✓ Docker CLI is available"
        if docker info &>/dev/null; then
            echo "✓ Docker daemon is accessible"
        else
            echo "⚠ Docker daemon is not accessible (may still be starting)"
        fi
    else
        echo "⚠ Docker CLI not found in PATH"
    fi

    # Check Docker Compose
    if command -v docker-compose &> /dev/null || docker compose version &>/dev/null 2>&1; then
        echo "✓ Docker Compose is available"
    else
        echo "⚠ Docker Compose not available"
    fi

    echo
    echo "Next steps:"
    echo "1. If Docker Desktop is not running, start it:"
    echo "   - From Applications menu: Search for 'Docker Desktop'"
    echo "   - From terminal: systemctl --user start docker-desktop"
    echo
    echo "2. Accept the Docker Subscription Service Agreement when prompted"
    echo
    echo "3. Test Docker with:"
    echo "   docker run hello-world"
    echo
    echo "4. Verify versions:"
    echo "   docker --version"
    echo "   docker compose version"
    echo

    if [[ $DESKTOP_ENV == "GNOME" ]]; then
        echo "5. GNOME users: If AppIndicator extension is not working, install it manually:"
        echo "   https://extensions.gnome.org/extension/615/appindicator-support/"
        echo
    fi

    if getent group docker > /dev/null 2>&1; then
        echo "6. Group changes take effect after logout/login or run:"
        echo "   newgrp docker"
        echo
    fi

    echo "For troubleshooting and more information, visit:"
    if [[ $OS_ID == "ubuntu" ]]; then
        echo "https://docs.docker.com/desktop/setup/install/linux/ubuntu/"
    else
        echo "https://docs.docker.com/desktop/setup/install/linux/debian/"
    fi
    echo
}

# Main installation process
main() {
    echo "=================================================="
    echo "Docker Desktop Installation Script for Ubuntu/Debian"
    echo "=================================================="
    echo

    check_not_root
    detect_os_version
    check_system_requirements
    detect_desktop_environment
    check_existing_docker

    # Confirm installation
    echo
    log_info "Ready to install Docker Desktop with the following configuration:"
    echo "  - OS: $OS_NAME $OS_VERSION"
    echo "  - Architecture: $ARCH"
    echo "  - Memory: ${MEMORY_GB}GB"
    echo "  - Desktop: $DESKTOP_ENV"
    echo

    read -p "Do you want to proceed with the installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled by user"
        exit 0
    fi

    # Installation steps
    install_prerequisites
    download_docker_desktop
    install_docker_desktop
    configure_docker_desktop

    # Post-installation setup and automation
    if [[ $SKIP_AUTO_SETUP == "false" ]]; then
        post_installation_setup
    else
        log_info "Skipping automated post-installation setup (--manual-setup specified)"
    fi

    # Verification and completion
    if verify_installation; then
        show_post_install_info
    else
        log_error "Installation verification failed. Please check the installation manually."
        exit 1
    fi
}

# Run main function
main "$@"
