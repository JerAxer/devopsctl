#!/usr/bin/env bash
# modules/report.sh - System Audit Report Generator

echo -e "${BLUE}===== SYSTEM AUDIT REPORT =====${NC}"

# Collect metrics
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
RAM=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')
DISK=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
LOAD=$(uptime | awk -F 'load average:' '{print $2}')
SERVICES=$(systemctl list-units --type=service --state=running | wc -l)
OPEN_PORTS=$(ss -tulpn | grep LISTEN | wc -l)

REPORT_DIR="${BACKUP_DIR}/reports"
mkdir -p "$REPORT_DIR"
REPORT_HTML="${REPORT_DIR}/report_$(date +%Y%m%d_%H%M%S).html"
REPORT_TXT="${REPORT_DIR}/report_$(date +%Y%m%d_%H%M%S).txt"

# 1. Generate HTML Report
cat > "$REPORT_HTML" << EOF
<!DOCTYPE html>
<html>
<head><title>devopsctl - System Report</title>
<style>
body { font-family: monospace; background: #1e1e2e; color: #cdd6f4; padding: 20px; }
h1 { color: #89b4fa; }
.box { background: #313244; padding: 15px; border-radius: 8px; margin: 10px 0; }
.good { color: #a6e3a1; } .warn { color: #f9e2af; } .bad { color: #f38ba8; }
table { width: 100%; text-align: left; }
td { padding: 5px; }
</style>
</head>
<body>
<h1>🚀 devopsctl - System Audit Report</h1>
<p>Generated: $(date)</p>
<div class="box">
<h2>📊 System Resources</h2>
<table>
<tr><td>CPU Usage</td><td class="$([ $CPU -gt 80 ] && echo 'bad' || echo 'good')">$CPU%</td></tr>
<tr><td>RAM Usage</td><td class="$([ $RAM -gt 80 ] && echo 'bad' || echo 'good')">$RAM%</td></tr>
<tr><td>Disk Usage</td><td class="$([ $DISK -gt 85 ] && echo 'bad' || echo 'good')">$DISK%</td></tr>
<tr><td>Load Average</td><td>$LOAD</td></tr>
</table>
</div>
<div class="box">
<h2>🖥️ Services & Security</h2>
<table>
<tr><td>Running Services</td><td>$SERVICES</td></tr>
<tr><td>Open Ports</td><td>$OPEN_PORTS</td></tr>
<tr><td>UFW Status</td><td>$(sudo ufw status | grep -q "active" && echo "✅ Active" || echo "❌ Inactive")</td></tr>
<tr><td>Fail2Ban</td><td>$(sudo systemctl is-active fail2ban --quiet && echo "✅ Running" || echo "❌ Stopped")</td></tr>
</table>
</div>
<div class="box">
<h2>📂 Top 5 CPU Processes</h2>
$(ps -eo pcpu,user,args --sort=-pcpu | head -6 | awk '{print $0 "<br>"}')
</div>
</body>
</html>
EOF

# 2. Generate TXT Report (for CLI)
cat > "$REPORT_TXT" << EOF
=======================================
 DEVOPSCTL SYSTEM AUDIT REPORT
 Date: $(date)
=======================================
 CPU Usage    : $CPU%
 RAM Usage    : $RAM%
 Disk Usage   : $DISK%
 Load Avg     : $LOAD
 Running Svc  : $SERVICES
 Open Ports   : $OPEN_PORTS
---------------------------------------
 Top Processes:
$(ps -eo pcpu,pid,user,args --sort=-pcpu | head -6)
=======================================
EOF

log "SUCCESS" "Reports generated in $REPORT_DIR"
echo -e "${GREEN}HTML Report: $REPORT_HTML${NC}"
echo -e "${GREEN}TXT Report:  $REPORT_TXT${NC}"

# Attempt to open HTML in browser if desktop
if [[ -n "$DISPLAY" ]]; then
    xdg-open "$REPORT_HTML" 2>/dev/null || sensible-browser "$REPORT_HTML" 2>/dev/null || echo "Open the HTML manually."
fi