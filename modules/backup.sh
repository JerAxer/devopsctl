#!/usr/bin/env bash
# modules/backup.sh - Backup & Restore System

echo -e "${BLUE}===== BACKUP SYSTEM =====${NC}"

# Ensure backup dir exists
mkdir -p "$BACKUP_DIR"

# Function: Backup a folder
backup_folder() {
    local source_path="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_$(basename "$source_path")_$timestamp.tar.gz"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    echo "Backing up $source_path to $backup_path..."
    sudo tar -czf "$backup_path" -C "$(dirname "$source_path")" "$(basename "$source_path")" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "Folder backup created: $backup_name"
        echo -e "${GREEN}Backup saved: $backup_path${NC}"
    else
        log "ERROR" "Failed to backup $source_path"
    fi
}

# Function: Backup Database (MySQL/PostgreSQL)
backup_database() {
    echo "Detecting installed databases..."
    
    # MySQL / MariaDB
    if command -v mysql &> /dev/null; then
        read -p "Enter MySQL DB name to backup (leave blank to skip): " db_name
        if [[ -n "$db_name" ]]; then
            read -sp "MySQL Root Password: " db_pass
            echo
            sudo mysqldump -u root -p"$db_pass" "$db_name" > "${BACKUP_DIR}/${db_name}_$(date +%Y%m%d).sql"
            gzip "${BACKUP_DIR}/${db_name}_$(date +%Y%m%d).sql"
            log "SUCCESS" "MySQL DB $db_name backed up."
        fi
    fi
    
    # PostgreSQL
    if command -v psql &> /dev/null; then
        read -p "Enter PostgreSQL DB name to backup (leave blank to skip): " pg_db
        if [[ -n "$pg_db" ]]; then
            sudo -u postgres pg_dump "$pg_db" > "${BACKUP_DIR}/${pg_db}_$(date +%Y%m%d).sql"
            gzip "${BACKUP_DIR}/${pg_db}_$(date +%Y%m%d).sql"
            log "SUCCESS" "PostgreSQL DB $pg_db backed up."
        fi
    fi
}

# Function: Restore from a backup
restore_backup() {
    echo -e "${YELLOW}Available backups in $BACKUP_DIR:${NC}"
    ls -lh "$BACKUP_DIR" | grep ".tar.gz\|.sql.gz"
    
    read -p "Enter exact filename to restore: " restore_file
    local full_path="${BACKUP_DIR}/$restore_file"
    
    if [[ ! -f "$full_path" ]]; then
        log "ERROR" "File not found."
        return
    fi
    
    confirm "Restore $restore_file (this will overwrite existing files)?" || exit 0
    
    if [[ "$restore_file" == *.tar.gz ]]; then
        sudo tar -xzf "$full_path" -C /
        log "SUCCESS" "Folder restore completed."
    elif [[ "$restore_file" == *.sql.gz ]]; then
        gunzip -c "$full_path" | sudo mysql -u root -p
        log "SUCCESS" "Database restore completed."
    else
        log "ERROR" "Unsupported file format."
    fi
}

# --- Main Interactive Menu ---
echo "1) Backup a Folder (e.g., /var/www)"
echo "2) Backup a Database (MySQL/PG)"
echo "3) Restore from Backup"
read -p "Select option: " backup_choice

case $backup_choice in
    1) 
        read -p "Enter absolute folder path to backup: " folder_path
        if [[ -d "$folder_path" ]]; then
            backup_folder "$folder_path"
        else
            log "ERROR" "Path does not exist."
        fi
        ;;
    2) backup_database ;;
    3) restore_backup ;;
    *) echo "Invalid option." ;;
esac