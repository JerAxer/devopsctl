#!/usr/bin/env bash
# modules/report.sh - Enhanced System Audit Report Generator

echo -e "${BLUE}===== SYSTEM AUDIT REPORT =====${NC}"

# Load config (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../config/settings.conf"

# SSH password (same as in remote.sh)
SSH_PASS="${SSH_PASS:-devops123}"

# Function to collect metrics from a local or remote server
collect_metrics() {
    local server="$1"
    
    if [[ "$server" == "localhost" ]] || [[ -z "$server" ]]; then
        # Local metrics
        CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1 2>/dev/null || echo "0")
        RAM=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }' 2>/dev/null || echo "0")
        DISK=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
        LOAD=$(uptime | awk -F 'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//g' 2>/dev/null || echo "0")
        UPTIME=$(uptime -p | sed 's/up //' 2>/dev/null || echo "N/A")
        PROCESSES=$(ps aux | wc -l 2>/dev/null || echo "0")
        NETSTAT=$(ss -tulpn 2>/dev/null | grep LISTEN | wc -l || netstat -tulpn 2>/dev/null | grep LISTEN | wc -l || echo "0")
        HOSTNAME=$(hostname)
        KERNEL=$(uname -r)
        OS=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown OS")
    else
        # Remote metrics via SSH with sshpass
        HOSTNAME=$(sshpass -p "$SSH_PASS" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$server" "hostname" 2>/dev/null || echo "Unreachable")
        if [[ "$HOSTNAME" != "Unreachable" ]]; then
            local remote_data=$(sshpass -p "$SSH_PASS" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$server" "
                echo \"CPU:\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d. -f1 2>/dev/null || echo 0)\"
                echo \"RAM:\$(free -m | awk 'NR==2{printf \"%.0f\", \$3*100/\$2 }' 2>/dev/null || echo 0)\"
                echo \"DISK:\$(df -h / | awk 'NR==2{print \$5}' | sed 's/%//' 2>/dev/null || echo 0)\"
                echo \"LOAD:\$(uptime | awk -F 'load average:' '{print \$2}' | awk '{print \$1}' | sed 's/,//g' 2>/dev/null || echo 0)\"
                echo \"UPTIME:\$(uptime -p | sed 's/up //' 2>/dev/null || echo 'N/A')\"
                echo \"PROCESSES:\$(ps aux | wc -l 2>/dev/null || echo 0)\"
                echo \"NETSTAT:\$(ss -tulpn 2>/dev/null | grep LISTEN | wc -l || netstat -tulpn 2>/dev/null | grep LISTEN | wc -l || echo 0)\"
                echo \"KERNEL:\$(uname -r 2>/dev/null || echo 'Unknown')\"
                echo \"OS:\$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'\"' -f2 || echo 'Unknown OS')\"
            " 2>/dev/null)
            
            # Parse remote data
            CPU=$(echo "$remote_data" | grep "^CPU:" | cut -d: -f2)
            RAM=$(echo "$remote_data" | grep "^RAM:" | cut -d: -f2)
            DISK=$(echo "$remote_data" | grep "^DISK:" | cut -d: -f2)
            LOAD=$(echo "$remote_data" | grep "^LOAD:" | cut -d: -f2)
            UPTIME=$(echo "$remote_data" | grep "^UPTIME:" | cut -d: -f2)
            PROCESSES=$(echo "$remote_data" | grep "^PROCESSES:" | cut -d: -f2)
            NETSTAT=$(echo "$remote_data" | grep "^NETSTAT:" | cut -d: -f2)
            KERNEL=$(echo "$remote_data" | grep "^KERNEL:" | cut -d: -f2)
            OS=$(echo "$remote_data" | grep "^OS:" | cut -d: -f2)
        else
            CPU="N/A"
            RAM="N/A"
            DISK="N/A"
            LOAD="N/A"
            UPTIME="N/A"
            PROCESSES="N/A"
            NETSTAT="N/A"
            KERNEL="N/A"
            OS="N/A"
        fi
    fi
}

# Function to get color class for thresholds
get_color() {
    local value="$1"
    local threshold="$2"
    
    if [[ "$value" == "N/A" ]]; then
        echo "na"
    elif [[ $value -gt $threshold ]]; then
        echo "bad"
    elif [[ $value -gt $((threshold - 20)) ]]; then
        echo "warn"
    else
        echo "good"
    fi
}

# --- Collect Data from All Servers ---

# Parse servers list
if [[ -z "$SERVERS_LIST" ]]; then
    SERVERS=("localhost")
else
    IFS=',' read -ra SERVERS <<< "$SERVERS_LIST"
fi

# Create report directory
REPORT_DIR="${BACKUP_DIR:-/reports}/reports"
mkdir -p "$REPORT_DIR"
REPORT_HTML="${REPORT_DIR}/report_$(date +%Y%m%d_%H%M%S).html"
REPORT_TXT="${REPORT_DIR}/report_$(date +%Y%m%d_%H%M%S).txt"

# --- Generate HTML Report ---

cat > "$REPORT_HTML" << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
<title>devopsctl - System Audit Report</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { 
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #0d1117;
    color: #c9d1d9;
    padding: 20px;
}
.container { max-width: 1200px; margin: 0 auto; }
h1 { 
    color: #58a6ff;
    font-size: 2.5em;
    border-bottom: 2px solid #30363d;
    padding-bottom: 10px;
    margin-bottom: 20px;
}
h2 { 
    color: #58a6ff;
    font-size: 1.5em;
    margin: 20px 0 10px 0;
}
.timestamp { color: #8b949e; margin-bottom: 20px; }
.summary-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
    margin: 20px 0;
}
.stat-box {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 8px;
    padding: 15px;
    text-align: center;
}
.stat-box .value {
    font-size: 2em;
    font-weight: bold;
    display: block;
}
.stat-box .label {
    font-size: 0.9em;
    color: #8b949e;
    margin-top: 5px;
}
.server-card {
    background: #161b22;
    border: 1px solid #30363d;
    border-radius: 8px;
    padding: 20px;
    margin: 15px 0;
}
.server-card h3 {
    color: #58a6ff;
    margin-bottom: 10px;
}
.server-card .hostname {
    color: #f0883e;
    font-weight: bold;
}
.server-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 10px;
    margin: 10px 0;
}
.good { color: #3fb950; }
.warn { color: #d29922; }
.bad { color: #f85149; }
.na { color: #8b949e; }
table { 
    width: 100%; 
    border-collapse: collapse;
    margin: 10px 0;
}
td, th {
    padding: 8px 12px;
    text-align: left;
    border-bottom: 1px solid #21262d;
}
th {
    color: #8b949e;
    font-weight: normal;
}
.footer {
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #30363d;
    color: #8b949e;
    font-size: 0.9em;
    text-align: center;
}
</style>
</head>
<body>
<div class="container">
HTML_HEADER

# Add title
echo "<h1>🚀 devopsctl - System Audit Report</h1>" >> "$REPORT_HTML"
echo "<div class='timestamp'>Generated: $(date)</div>" >> "$REPORT_HTML"

# --- Summary Statistics ---
echo "<h2>📊 Cluster Summary</h2>" >> "$REPORT_HTML"
echo "<div class='summary-grid'>" >> "$REPORT_HTML"

# Collect summary stats from all servers
TOTAL_SERVERS=${#SERVERS[@]}
TOTAL_CPU=0
TOTAL_RAM=0
TOTAL_DISK=0
CPU_COUNT=0
RAM_COUNT=0
DISK_COUNT=0

for server in "${SERVERS[@]}"; do
    collect_metrics "$server"
    if [[ "$CPU" != "N/A" ]] && [[ -n "$CPU" ]]; then
        TOTAL_CPU=$((TOTAL_CPU + CPU))
        CPU_COUNT=$((CPU_COUNT + 1))
    fi
    if [[ "$RAM" != "N/A" ]] && [[ -n "$RAM" ]]; then
        TOTAL_RAM=$((TOTAL_RAM + RAM))
        RAM_COUNT=$((RAM_COUNT + 1))
    fi
    if [[ "$DISK" != "N/A" ]] && [[ -n "$DISK" ]]; then
        TOTAL_DISK=$((TOTAL_DISK + DISK))
        DISK_COUNT=$((DISK_COUNT + 1))
    fi
done

# Safely compute averages
if [[ $CPU_COUNT -gt 0 ]]; then
    AVG_CPU=$((TOTAL_CPU / CPU_COUNT))
else
    AVG_CPU="N/A"
fi
if [[ $RAM_COUNT -gt 0 ]]; then
    AVG_RAM=$((TOTAL_RAM / RAM_COUNT))
else
    AVG_RAM="N/A"
fi
if [[ $DISK_COUNT -gt 0 ]]; then
    AVG_DISK=$((TOTAL_DISK / DISK_COUNT))
else
    AVG_DISK="N/A"
fi

echo "<div class='stat-box'><span class='value'>$TOTAL_SERVERS</span><span class='label'>Total Servers</span></div>" >> "$REPORT_HTML"
echo "<div class='stat-box'><span class='value $([[ $AVG_CPU != "N/A" ]] && get_color "$AVG_CPU" 80)'>$AVG_CPU%</span><span class='label'>Avg CPU</span></div>" >> "$REPORT_HTML"
echo "<div class='stat-box'><span class='value $([[ $AVG_RAM != "N/A" ]] && get_color "$AVG_RAM" 80)'>$AVG_RAM%</span><span class='label'>Avg RAM</span></div>" >> "$REPORT_HTML"
echo "<div class='stat-box'><span class='value $([[ $AVG_DISK != "N/A" ]] && get_color "$AVG_DISK" 85)'>$AVG_DISK%</span><span class='label'>Avg Disk</span></div>" >> "$REPORT_HTML"

echo "</div>" >> "$REPORT_HTML"

# --- Per-Server Details ---
echo "<h2>🖥️ Server Details</h2>" >> "$REPORT_HTML"

for server in "${SERVERS[@]}"; do
    collect_metrics "$server"
    
    echo "<div class='server-card'>" >> "$REPORT_HTML"
    echo "<h3>📡 <span class='hostname'>$HOSTNAME</span> <span style='font-size:0.7em;color:#8b949e;'>($server)</span></h3>" >> "$REPORT_HTML"
    echo "<div class='server-grid'>" >> "$REPORT_HTML"
    
    # CPU
    color=$(get_color "$CPU" 80)
    echo "<div><strong>CPU:</strong> <span class='$color'>$CPU%</span></div>" >> "$REPORT_HTML"
    
    # RAM
    color=$(get_color "$RAM" 80)
    echo "<div><strong>RAM:</strong> <span class='$color'>$RAM%</span></div>" >> "$REPORT_HTML"
    
    # Disk
    color=$(get_color "$DISK" 85)
    echo "<div><strong>Disk:</strong> <span class='$color'>$DISK%</span></div>" >> "$REPORT_HTML"
    
    # Load
    echo "<div><strong>Load:</strong> $LOAD</div>" >> "$REPORT_HTML"
    
    echo "</div>" >> "$REPORT_HTML"
    echo "<div class='server-grid'>" >> "$REPORT_HTML"
    
    # Uptime
    echo "<div><strong>Uptime:</strong> $UPTIME</div>" >> "$REPORT_HTML"
    
    # Processes
    echo "<div><strong>Processes:</strong> $PROCESSES</div>" >> "$REPORT_HTML"
    
    # Open Ports
    echo "<div><strong>Open Ports:</strong> $NETSTAT</div>" >> "$REPORT_HTML"
    
    # Kernel
    echo "<div><strong>Kernel:</strong> $KERNEL</div>" >> "$REPORT_HTML"
    
    echo "</div>" >> "$REPORT_HTML"
    echo "<div style='margin-top:10px;font-size:0.85em;color:#8b949e;'><strong>OS:</strong> $OS</div>" >> "$REPORT_HTML"
    echo "</div>" >> "$REPORT_HTML"
done

# --- Footer ---
cat >> "$REPORT_HTML" << 'HTML_FOOTER'
<div class="footer">
    Generated by <strong>devopsctl</strong> | DevOps Toolkit v1.1.0<br>
    Developed by MK youcef
</div>
</div>
</body>
</html>
HTML_FOOTER

# --- Generate TXT Report ---

cat > "$REPORT_TXT" << TXT_HEADER
=======================================
 DEVOPSCTL SYSTEM AUDIT REPORT
 Generated: $(date)
=======================================
Total Servers: ${#SERVERS[@]}
---------------------------------------

TXT_HEADER

for server in "${SERVERS[@]}"; do
    collect_metrics "$server"
    
    cat >> "$REPORT_TXT" << TXT_SERVER
📡 SERVER: $HOSTNAME ($server)
---------------------------------------
  CPU        : $CPU%  $(if [[ $CPU -gt 80 ]]; then echo "[!] HIGH"; elif [[ $CPU -gt 60 ]]; then echo "[!] WARN"; else echo "[OK]"; fi)
  RAM        : $RAM%  $(if [[ $RAM -gt 80 ]]; then echo "[!] HIGH"; elif [[ $RAM -gt 60 ]]; then echo "[!] WARN"; else echo "[OK]"; fi)
  Disk       : $DISK% $(if [[ $DISK -gt 85 ]]; then echo "[!] HIGH"; elif [[ $DISK -gt 70 ]]; then echo "[!] WARN"; else echo "[OK]"; fi)
  Load Avg   : $LOAD
  Uptime     : $UPTIME
  Processes  : $PROCESSES
  Open Ports : $NETSTAT
  Kernel     : $KERNEL
  OS         : $OS
---------------------------------------

TXT_SERVER
done

cat >> "$REPORT_TXT" << TXT_FOOTER
=======================================
 Generated by devopsctl v1.1.0
 Developed by MK youcef
=======================================
TXT_FOOTER

# --- Final Output ---
log "SUCCESS" "Reports generated in $REPORT_DIR"
echo -e "${GREEN}HTML Report: $REPORT_HTML${NC}"
echo -e "${GREEN}TXT Report:  $REPORT_TXT${NC}"

# --- Copy to /app for easy access on Windows ---
mkdir -p /app/reports
cp "$REPORT_HTML" /app/reports/
cp "$REPORT_TXT" /app/reports/

echo -e "${GREEN}Reports also copied to /app/reports/ for Windows access${NC}"
