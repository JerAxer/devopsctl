#!/usr/bin/env bash
# modules/setup.sh

echo -e "${BLUE}===== SERVER SETUP =====${NC}"
confirm "Install essential packages (git, curl, docker, nginx)?" || exit 0

log "INFO" "Updating package lists..."
sudo apt update -y

log "INFO" "Installing base packages..."
sudo apt install -y git curl wget nginx ufw fail2ban

# Docker
if ! command -v docker &> /dev/null; then
    log "INFO" "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
fi

log "SUCCESS" "Setup completed. System is ready."