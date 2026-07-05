#!/usr/bin/env bash
# install.sh - Global Installer for devopsctl
# Run this script with: bash install.sh

set -e

VERSION="1.0.0"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/devopsctl"
DATA_DIR="/var/lib/devopsctl"

echo -e "\033[0;34m"
cat << "EOF"
  _____                      _        _____ _ _      
 |  __ \                    | |      / ____| | |     
 | |  | | ___  ___  ___  ___| |_    | |    | | | ___ 
 | |  | |/ _ \/ _ \/ _ \/ __| __|   | |    | | |/ _ \
 | |__| |  __/  __/  __/\__ \ |_    | |____| | |  __/
 |_____/ \___|\___|\___||___/\__|    \_____|_|_|\___|
                                                      
EOF
echo -e "\033[0m"
echo "DevOps Toolkit CLI v$VERSION - Installer"
echo "========================================="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "[✓] Linux detected."
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "[⚠] Windows (Git Bash) detected. Installing to user directory."
    INSTALL_DIR="$HOME/bin"
    mkdir -p "$INSTALL_DIR"
else
    echo "[⚠] Unknown OS. Installing to user directory."
    INSTALL_DIR="$HOME/bin"
    mkdir -p "$INSTALL_DIR"
fi

# 1. Create global directories
echo "[1/5] Creating system directories..."
sudo mkdir -p "$DATA_DIR" "$CONFIG_DIR" 2>/dev/null || mkdir -p "$DATA_DIR" "$CONFIG_DIR"

# 2. Copy the main script
echo "[2/5] Installing devopsctl binary..."
sudo cp devopsctl "$INSTALL_DIR/devopsctl" 2>/dev/null || cp devopsctl "$INSTALL_DIR/devopsctl"
sudo chmod +x "$INSTALL_DIR/devopsctl" 2>/dev/null || chmod +x "$INSTALL_DIR/devopsctl"

# 3. Copy modules and libraries
echo "[3/5] Installing modules and libraries..."
sudo cp -r modules "$DATA_DIR/" 2>/dev/null || cp -r modules "$DATA_DIR/"
sudo cp -r lib "$DATA_DIR/" 2>/dev/null || cp -r lib "$DATA_DIR/"
sudo cp -r config "$DATA_DIR/" 2>/dev/null || cp -r config "$DATA_DIR/"

# 4. Create a symlink for the config file (so user can edit it easily)
echo "[4/5] Linking configuration..."
if [[ -f "/etc/devopsctl/settings.conf" ]]; then
    sudo rm "/etc/devopsctl/settings.conf" 2>/dev/null
fi
sudo cp config/settings.conf "$CONFIG_DIR/settings.conf" 2>/dev/null || cp config/settings.conf "$CONFIG_DIR/settings.conf"
echo "   Configuration stored at: $CONFIG_DIR/settings.conf"

# 5. Update the main script to point to the installed modules
echo "[5/5] Finalizing installation..."
# The devopsctl script uses relative paths. We patch it to use absolute paths.
SED_CMD="sed -i"
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_CMD="sed -i ''"
fi

# Replace SCRIPT_DIR to point to the data directory
$SED_CMD "s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"|SCRIPT_DIR=\"$DATA_DIR\"|g" "$INSTALL_DIR/devopsctl"

# Add PATH update to .bashrc if not already there
if ! grep -q "devopsctl" ~/.bashrc 2>/dev/null; then
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> ~/.bashrc
    echo "[✓] Added $INSTALL_DIR to PATH in ~/.bashrc"
fi

# Done
echo ""
echo -e "\033[0;32m========================================="
echo "✅ INSTALLATION COMPLETE!"
echo "========================================="
echo -e "\033[0m"
echo "You can now run:"
echo "  devopsctl --help"
echo "  devopsctl (for interactive menu)"
echo ""
echo "To configure your servers and paths, edit:"
echo "  $CONFIG_DIR/settings.conf"
echo ""
echo "To upgrade in the future, simply re-run this installer."