#!/usr/bin/env bash
# modules/logs.sh

echo -e "${BLUE}===== LOG VIEWER =====${NC}"
tail -n 50 "$LOG_FILE" | while read line; do
    if echo "$line" | grep -q "ERROR"; then
        echo -e "${RED}$line${NC}"
    elif echo "$line" | grep -q "WARN"; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo "$line"
    fi
done