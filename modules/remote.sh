#!/usr/bin/env bash
# modules/remote.sh - Multi-Server Orchestration Engine

echo -e "${BLUE}===== MULTI-SERVER ORCHESTRATOR =====${NC}"

# Load config if servers list not loaded
if [[ -z "$SERVERS_LIST" ]]; then
    source "$(dirname "$0")/../config/settings.conf"
fi

if [[ -z "$SERVERS_LIST" ]]; then
    log "ERROR" "SERVERS_LIST is empty. Add servers to config/settings.conf"
    echo -e "${RED}Format: user@ip,user@ip2${NC}"
    exit 1
fi

# Split the comma-separated list into an array
IFS=',' read -ra SERVERS <<< "$SERVERS_LIST"

# Function to run a command on a single server
run_remote() {
    local server="$1"
    local cmd="$2"
    
    echo -e "${YELLOW}--- Running on: $server ---${NC}"
    sshpass -p "devops123" ssh -o ConnectTimeout=30 -o StrictHostKeyChecking=no "$server" "$cmd" 2>&1
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log "WARN" "Command failed on $server (exit code: $exit_code)"
    fi
}

# Function to copy a file to all servers (bonus feature)
copy_remote() {
    local source_file="$1"
    local dest_path="$2"
    
    if [[ ! -f "$source_file" ]]; then
        log "ERROR" "Source file $source_file not found."
        return
    fi
    
    for server in "${SERVERS[@]}"; do
        echo -e "${YELLOW}--- Copying to: $server ---${NC}"
        sshpass -p "devops123" scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no "$source_file" "${server}:${dest_path}"
    done
    log "SUCCESS" "File copied to all servers."
}

# --- Main Interactive Menu ---
echo "1) Run a devopsctl command on all servers"
echo "2) Run a custom shell command on all servers"
echo "3) Copy a file to all servers"
echo "4) List all configured servers"
read -p "Select option: " remote_choice

case $remote_choice in
    1)
        echo "Available commands: setup, deploy, monitor, docker, backup, secure, logs, clean, report"
        read -p "Enter devopsctl command to run remotely: " cmd
        for server in "${SERVERS[@]}"; do
            # We copy the entire devopsctl directory to the remote server's /tmp and run it
            # This ensures the remote server has the tool without needing installation
            echo -e "${BLUE}Syncing devopsctl to $server...${NC}"
            scp -r "$(dirname "$0")/.." "${server}:/tmp/devopsctl_remote" 2>/dev/null
            run_remote "$server" "cd /tmp/devopsctl_remote && chmod +x devopsctl && ./devopsctl $cmd --force"
        done
        ;;
    2)
        read -p "Enter custom shell command (e.g., 'df -h'): " custom_cmd
        for server in "${SERVERS[@]}"; do
            run_remote "$server" "$custom_cmd"
        done
        ;;
    3)
        read -p "Local file path to copy: " src
        read -p "Remote destination path: " dest
        copy_remote "$src" "$dest"
        ;;
    4)
        echo -e "${GREEN}Configured Servers:${NC}"
        for server in "${SERVERS[@]}"; do
            echo "  - $server"
        done
        ;;
    *)
        echo "Invalid option."
        ;;
esac