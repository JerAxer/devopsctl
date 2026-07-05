#!/usr/bin/env bash
# lib/common.sh - Core functions for devopsctl

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Global Log File
LOG_FILE="${LOG_DIR:-./logs}/devopsctl.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Logger
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    
    case $level in
        "INFO")  echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}[✔]${NC} $message" ;;
        *)       echo "$message" ;;
    esac
}

# Safety: Ask for confirmation
confirm() {
    local prompt="$1"
    if [[ "$FORCE" == "true" ]]; then
        return 0  # Skip confirmation if --force flag is set
    fi
    read -p "$prompt (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        log "INFO" "User cancelled operation."
        return 1
    fi
}

# Safety: Check safe mode before destructive actions
check_safe_mode() {
    if [[ "$SAFE_MODE" == "true" ]] && [[ "$FORCE" != "true" ]]; then
        log "ERROR" "Destructive action blocked. Use --force or disable SAFE_MODE in config."
        echo -e "${RED}SAFE_MODE is enabled. Use '--force' to override.${NC}"
        exit 1
    fi
}

# Load configuration
load_config() {
    if [[ -f "config/settings.conf" ]]; then
        source "config/settings.conf"
        log "INFO" "Configuration loaded successfully."
    else
        echo -e "${YELLOW}Warning: config/settings.conf not found. Using defaults.${NC}"
    fi
}

# Trap errors
trap 'log "ERROR" "Command failed on line $LINENO"' ERR