#!/usr/bin/env bash
# modules/monitor.sh

echo -e "${BLUE}===== SYSTEM MONITOR =====${NC}"

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
RAM=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')
DISK=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
LOAD=$(uptime | awk -F 'load average:' '{print $2}')

echo "CPU Usage : $CPU% (Threshold: ${ALERT_CPU}%)"
echo "RAM Usage : $RAM% (Threshold: ${ALERT_RAM}%)"
echo "Disk Usage: $DISK% (Threshold: ${ALERT_DISK}%)"
echo "Load Avg  : $LOAD"
echo "Top 5 Processes by CPU:"
ps -eo pcpu,pid,user,args --sort=-pcpu | head -6

# Alerts
[[ $CPU -gt $ALERT_CPU ]] && log "WARN" "CPU exceeds threshold! ($CPU%)"
[[ $RAM -gt $ALERT_RAM ]] && log "WARN" "RAM exceeds threshold! ($RAM%)"
log "INFO" "Monitor executed."