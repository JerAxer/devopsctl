#!/usr/bin/env bash
# modules/secure.sh - Security Hardening

echo -e "${BLUE}===== SECURITY HARDENING =====${NC}"

# Load config if not already loaded
if [[ -z "$FIREWALL_PORTS" ]]; then
    source "$(dirname "$0")/../config/settings.conf"
fi

# 1. Firewall (UFW)
setup_firewall() {
    echo -e "${YELLOW}Configuring UFW Firewall...${NC}"
    sudo ufw --force disable 2>/dev/null # Reset
    echo "Allowing ports: $FIREWALL_PORTS"
    IFS=',' read -ra PORTS <<< "$FIREWALL_PORTS"
    for port in "${PORTS[@]}"; do
        sudo ufw allow "$port"
    done
    sudo ufw --force enable
    log "INFO" "Firewall configured with ports: $FIREWALL_PORTS"
}

# 2. Fail2Ban
setup_fail2ban() {
    echo -e "${YELLOW}Installing & Configuring Fail2Ban...${NC}"
    sudo apt install fail2ban -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    log "INFO" "Fail2Ban installed and running."
}

# 3. Disable Root SSH (Optional)
harden_ssh() {
    if [[ "$DISABLE_ROOT_SSH" == "yes" ]]; then
        echo -e "${YELLOW}Disabling Root SSH login...${NC}"
        sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo systemctl restart sshd
        log "WARN" "Root SSH login has been DISABLED. Make sure you have a sudo user!"
    else
        echo -e "${GREEN}Root SSH login is allowed (as per config).${NC}"
    fi
}

# 4. Security Audit (Read-only scan)
security_audit() {
    echo -e "${BLUE}--- Quick Security Audit ---${NC}"
    echo "1. Open Ports:"
    ss -tulpn | grep LISTEN | column -t
    
    echo -e "\n2. SSH Config (Root login):"
    sudo grep "^PermitRootLogin" /etc/ssh/sshd_config || echo "PermitRootLogin not explicitly set."
    
    echo -e "\n3. UFW Status:"
    sudo ufw status | grep -v "Status: active" || echo "UFW is active."
    
    echo -e "\n4. Fail2Ban Status:"
    sudo systemctl is-active fail2ban --quiet && echo "Fail2Ban is RUNNING" || echo "Fail2Ban is STOPPED"
}

# --- Main Execution ---
check_safe_mode
confirm "Run full security hardening (UFW, Fail2Ban, SSH)?" || exit 0

setup_firewall
setup_fail2ban
harden_ssh
security_audit

log "SUCCESS" "Security hardening completed."
echo -e "${GREEN}[✔] Server is now hardened!${NC}"