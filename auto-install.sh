#!/usr/bin/env bash
# auto-install.sh - Zero-Touch Professional Installer
# Usage: bash auto-install.sh

set -e

VERSION="1.0.0"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- 1. Determine where the source code is ---
# This works even if you run it from a different directory, e.g., bash /path/to/devopsctl/auto-install.sh
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SOURCE_DIR"

echo -e "${BLUE}"
cat << "EOF"
  _____                      _        _____ _ _      
 |  __ \                    | |      / ____| | |     
 | |  | | ___  ___  ___  ___| |_    | |    | | | ___ 
 | |  | |/ _ \/ _ \/ _ \/ __| __|   | |    | | |/ _ \
 | |__| |  __/  __/  __/\__ \ |_    | |____| | |  __/
 |_____/ \___|\___|\___||___/\__|    \_____|_|_|\___|
                                                      
EOF
echo -e "${NC}Auto-Installer v$VERSION"
echo "=============================="

# --- 2. Detect Operating System ---
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        BIN_DIR="/usr/local/bin"
        APP_DIR="/opt/devopsctl"
        PROFILE_FILE="$HOME/.bashrc"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        BIN_DIR="/usr/local/bin"
        APP_DIR="/opt/devopsctl"
        PROFILE_FILE="$HOME/.zshrc"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        BIN_DIR="$HOME/bin"
        APP_DIR="$HOME/devopsctl"
        PROFILE_FILE="$HOME/.bashrc"
        # Create bin if it doesn't exist
        mkdir -p "$BIN_DIR"
    else
        OS="unknown"
        BIN_DIR="$HOME/bin"
        APP_DIR="$HOME/devopsctl"
        PROFILE_FILE="$HOME/.bashrc"
    fi
    echo -e "${GREEN}[✓] Detected OS: $OS${NC}"
}

# --- 3. Install / Copy Files ---
install_files() {
    echo -e "${YELLOW}[1/4] Installing files to $APP_DIR...${NC}"
    
    # If installing to /opt, need sudo. If installing to /home, just copy.
    if [[ "$APP_DIR" == "/opt/devopsctl" ]]; then
        sudo mkdir -p "$APP_DIR"
        sudo cp -r "$SOURCE_DIR"/* "$APP_DIR/"
        sudo chmod +x "$APP_DIR/devopsctl"
        sudo chmod +x "$APP_DIR"/modules/*.sh 2>/dev/null || true
        sudo chmod +x "$APP_DIR"/lib/*.sh 2>/dev/null || true
    else
        mkdir -p "$APP_DIR"
        cp -r "$SOURCE_DIR"/* "$APP_DIR/"
        chmod +x "$APP_DIR/devopsctl"
        chmod +x "$APP_DIR"/modules/*.sh 2>/dev/null || true
        chmod +x "$APP_DIR"/lib/*.sh 2>/dev/null || true
    fi
    echo -e "${GREEN}[✓] Files installed.${NC}"
}

# --- 4. Create Global Symlink ---
create_symlink() {
    echo -e "${YELLOW}[2/4] Creating global command in $BIN_DIR...${NC}"
    
    if [[ "$APP_DIR" == "/opt/devopsctl" ]]; then
        sudo ln -sf "$APP_DIR/devopsctl" "$BIN_DIR/devopsctl"
    else
        ln -sf "$APP_DIR/devopsctl" "$BIN_DIR/devopsctl"
    fi
    
    echo -e "${GREEN}[✓] Symlink created.${NC}"
}

# --- 5. Update PATH in profile ---
update_path() {
    echo -e "${YELLOW}[3/4] Adding $BIN_DIR to PATH...${NC}"
    
    if ! grep -q "$BIN_DIR" "$PROFILE_FILE" 2>/dev/null; then
        echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$PROFILE_FILE"
        echo -e "${GREEN}[✓] Added $BIN_DIR to $PROFILE_FILE${NC}"
    else
        echo -e "${GREEN}[✓] PATH already configured.${NC}"
    fi
}

# --- 6. Verify installation ---
verify_install() {
    echo -e "${YELLOW}[4/4] Verifying installation...${NC}"
    
    # Source the profile to load new PATH in this session
    if [[ -f "$PROFILE_FILE" ]]; then
        source "$PROFILE_FILE" 2>/dev/null || true
    fi
    
    # Test the command
    if command -v devopsctl &> /dev/null; then
        echo -e "${GREEN}✅ SUCCESS! devopsctl is installed and ready.${NC}"
        echo ""
        echo "Try it now:"
        echo "  devopsctl --help"
        echo "  devopsctl monitor"
        echo ""
        echo "To configure your servers and thresholds, edit:"
        echo "  $APP_DIR/config/settings.conf"
        echo ""
        echo "If 'devopsctl' is not found in this terminal, please open a NEW terminal."
    else
        echo -e "${RED}❌ Installation failed. Please check permissions and try again.${NC}"
        exit 1
    fi
}

# --- 7. OS-Specific Warnings (Windows) ---
platform_notes() {
    if [[ "$OS" == "windows" ]]; then
        echo -e "${YELLOW}⚠️  Windows (Git Bash) detected.${NC}"
        echo "  - The 'secure' module requires a real Linux kernel (WSL or Docker)."
        echo "  - All other modules (monitor, backup, report, clean) will work perfectly."
        echo ""
        echo "For full security hardening, run this inside WSL or Docker:"
        echo "  docker run -it --rm -v \"\$(pwd):/app\" ubuntu:22.04 bash"
    elif [[ "$OS" == "linux" ]]; then
        echo -e "${GREEN}✅ Linux detected. Full feature set available.${NC}"
    elif [[ "$OS" == "macos" ]]; then
        echo -e "${GREEN}✅ macOS detected. Most features work natively (except ufw/fail2ban).${NC}"
    fi
}

# --- RUN THE INSTALLER ---
detect_os
install_files
create_symlink
update_path
verify_install
platform_notes

echo -e "${BLUE}=== Installation Complete ===${NC}"