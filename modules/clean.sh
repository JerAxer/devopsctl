#!/usr/bin/env bash
# modules/clean.sh

echo -e "${BLUE}===== SYSTEM CLEANER =====${NC}"
check_safe_mode
confirm "Delete system cache, old logs, and apt cache?" || exit 0

log "INFO" "Starting system clean..."
sudo apt-get clean -y
sudo apt-get autoremove -y
sudo journalctl --vacuum-time=3d
docker system prune -af 2>/dev/null || echo "Docker not installed, skipping."
log "SUCCESS" "System cleaned successfully."