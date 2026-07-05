#!/usr/bin/env bash
# modules/deploy.sh

echo -e "${BLUE}===== DEPLOYMENT SYSTEM =====${NC}"

if [[ "$1" == "--rollback" ]]; then
    LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/snapshot_*.tar.gz 2>/dev/null | head -1)
    if [[ -z "$LATEST_BACKUP" ]]; then
        log "ERROR" "No backup snapshots found for rollback."
        exit 1
    fi
    confirm "Rollback to ${LATEST_BACKUP}?" || exit 0
    sudo tar -xzf "$LATEST_BACKUP" -C /
    sudo systemctl restart nginx
    log "SUCCESS" "Rollback completed."
    exit 0
fi

# Normal Deploy
REPO_URL="${REPO_URL:-https://github.com/your-org/your-app.git}"
if [[ -z "$REPO_URL" ]]; then
    log "ERROR" "Set REPO_URL in config/settings.conf"
    exit 1
fi

confirm "Deploy latest code from $REPO_URL?" || exit 0

# Backup current
mkdir -p "$BACKUP_DIR"
sudo tar -czf "${BACKUP_DIR}/snapshot_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$PROJECT_DIR" . 2>/dev/null || log "WARN" "No existing project to backup."

# Pull and build
sudo rm -rf "$PROJECT_DIR"
sudo git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit

# Auto-detect build
if [[ -f "package.json" ]]; then
    npm install && npm run build
    sudo systemctl restart node-app 2>/dev/null || echo "Service restart skipped."
elif [[ -f "requirements.txt" ]]; then
    pip install -r requirements.txt
    sudo systemctl restart python-app 2>/dev/null || echo "Service restart skipped."
else
    echo "Static site detected. Restarting nginx..."
    sudo systemctl restart nginx
fi

log "SUCCESS" "Deployment finished! Use './devopsctl deploy --rollback' to revert."