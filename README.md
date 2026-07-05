# 🚀 devopsctl – DevOps Toolkit CLI

> **A production-grade, modular CLI tool to manage servers, deploy apps, monitor resources, and generate audit reports—all from a single command.**

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/JerAxer/devopsctl)
[![Bash](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**Developed with ❤️ by [MK youcef](https://github.com/JerAxer)**

---

## 📖 Overview

`devopsctl` is a **production-ready DevOps automation tool** for Linux servers (fully functional on macOS and Windows via Git Bash/WSL). It combines server provisioning, application deployment with instant rollback, real-time monitoring, security hardening, and multi-server orchestration into one elegant CLI.

**Whether you manage 1 server or 100, `devopsctl` puts the power of a senior DevOps engineer in your terminal.**

---

## ✨ Features

| Module | Description |
| :--- | :--- |
| **⚙️ Setup** | Installs Docker, Nginx, Git, and dependencies automatically |
| **🚀 Deploy** | Git-based deployment with automatic build detection and **one-command rollback** |
| **📊 Monitor** | Real-time CPU, RAM, Disk usage with threshold alerts |
| **🐳 Docker** | Manage containers, build images, and prune unused resources |
| **💾 Backup** | Compressed folder backups + MySQL/PostgreSQL dumps with versioning |
| **🔐 Security** | UFW firewall configuration, Fail2Ban setup, and SSH hardening |
| **📡 Logs** | Color-coded log viewer with automatic error detection |
| **🧹 Clean** | Safe system cleanup (cache, Docker garbage, old logs) |
| **📄 Report** | Generates beautiful **HTML & TXT** system audit reports |
| **🌐 Remote** | Execute commands across **multiple servers** simultaneously via SSH |

---

## 🛠️ Quick Install

### One-Liner Install (Recommended)

Just copy and paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/JerAxer/devopsctl/main/auto-install.sh | bash
```


### Manual Install
```bash
git clone https://github.com/JerAxer/devopsctl.git
cd devopsctl
bash auto-install.sh
```

### Windows Users
Use Git Bash (comes with Git for Windows)

Or use WSL (Windows Subsystem for Linux)

## 🚀 Getting Started
### 1. After Installation
The devopsctl command is now globally available. Open a new terminal and type:

```bash
devopsctl --help
```
### 2. Interactive Mode
Just type devopsctl to open the beautiful menu-driven interface:

```bash
devopsctl
```
```text
  _____                      _        _____ _ _
 |  __ \                    | |      / ____| | |
 | |  | | ___  ___  ___  ___| |_    | |    | | | ___
 | |  | |/ _ \/ _ \/ _ \/ __| __|   | |    | | |/ _ \
 | |__| |  __/  __/  __/\__ \ |_    | |____| | |  __/
 |_____/ \___|\___|\___||___/\__|    \_____|_|_|\___|

Version 1.1.0 - DevOps Production Toolkit
---------------------------------------------
 1) Setup Server   2) Deploy App    3) Monitor
 4) Docker Mgr     5) Backup        6) Security
 7) Logs           8) Clean         9) Report
10) Remote (Multi-Server)           0) Exit

Select option:
```
3. Command Line Mode
Run specific commands directly:

```bash
devopsctl <command> [options]
```
## 📋 Available Commands

Command	Description	Example
setup	Install dependencies and configure server	devopsctl setup
deploy	Deploy app from Git	devopsctl deploy
deploy --rollback	Revert to previous deployment	devopsctl deploy --rollback
monitor	Show system health (CPU/RAM/Disk)	devopsctl monitor
docker	Manage Docker containers & images	devopsctl docker
backup	Backup folders or databases	devopsctl backup
secure	Harden server (UFW, Fail2Ban)	devopsctl secure --force
logs	View and filter system logs	devopsctl logs
clean	Remove cache, temp, and unused packages	devopsctl clean --force
report	Generate HTML/TXT system audit report	devopsctl report
remote	Run commands on multiple servers via SSH	devopsctl remote
--help	Show help menu	devopsctl --help

## 🎯 Usage Examples

### Example 1: Monitor System Health

```bash
devopsctl monitor
Output:

text
===== SYSTEM MONITOR =====
CPU Usage : 12% (Threshold: 80%)
RAM Usage : 45% (Threshold: 80%)
Disk Usage: 38% (Threshold: 85%)
Load Avg  : 0.25, 0.10, 0.05
Top 5 Processes by CPU:
%CPU   PID USER     COMMAND
 5.2  1234 root     node app.js
 2.1  5678 root     nginx
...
[INFO] Monitor executed.
```
### Example 2: Generate a Report

```bash
devopsctl report
A beautiful HTML dashboard and a TXT summary are generated:

text
[✔] Reports generated in /var/backups/devopsctl/reports
HTML Report: /var/backups/devopsctl/reports/report_20260705_163846.html

TXT Report:  /var/backups/devopsctl/reports/report_20260705_163846.txt
```
### Example 3: Deploy an Application

```bash
devopsctl deploy
The tool will:

Pull the latest code from your Git repository

Detect the project type (Node.js, Python, or static)

Build the project

Restart the service

Create a backup snapshot for rollback
```

### Example 4: Rollback a Deployment

```bash
devopsctl deploy --rollback
Instantly reverts to the previous deployment snapshot.
```
### Example 5: Secure a Server

```bash
devopsctl secure --force
Configures:

UFW firewall (opens ports from config)

Fail2Ban (prevents brute force attacks)

SSH hardening (optional root login disable)
```

### Example 6: Multi-Server Orchestration

```bash
devopsctl remote
text
1) Run a devopsctl command on all servers
2) Run a custom shell command on all servers
3) Copy a file to all servers
4) List all configured servers
Select option: 2
Enter custom shell command: df -h
--- Running on: root@192.168.1.101 ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   12G   38G  24% /
--- Running on: root@192.168.1.102 ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   15G   35G  30% /
```
## ⚙️ Configuration
After installation, edit the configuration file to customize your environment:

```bash
# Linux/macOS
sudo nano /opt/devopsctl/config/settings.conf

# Windows (Git Bash)
nano ~/devopsctl/config/settings.conf
Key Configuration Options
bash
# Project paths
PROJECT_DIR="/var/www/myapp"          # Default deployment path
BACKUP_DIR="/var/backups/devopsctl"   # Where backups are stored
LOG_DIR="./logs"                      # Log directory

# Alert thresholds
ALERT_CPU=80          # CPU usage alert threshold (%)
ALERT_RAM=80          # RAM usage alert threshold (%)
ALERT_DISK=85         # Disk usage alert threshold (%)

# Security
DISABLE_ROOT_SSH="no"        # Set to "yes" to disable root SSH login
FIREWALL_PORTS="22,80,443"   # Ports to allow through firewall

# Deployment
REPO_URL="https://github.com/your-org/your-app.git"  # Your Git repository
APP_TYPE="node"     # Options: node, python, static

# Multi-Server Orchestration
SERVERS_LIST="root@192.168.1.101,root@192.168.1.102,ubuntu@staging-server"

# Safety
SAFE_MODE="true"          # Set to "false" to disable safety confirmations
```
## 🌐 Multi-Server Orchestration
Manage a fleet of servers from one terminal.

### Setup (Production Servers)
Configure SSH key authentication (passwordless):

```bash
ssh-keygen -t rsa
ssh-copy-id root@192.168.1.101
ssh-copy-id root@192.168.1.102
Add servers to config:
```
----

```bash
SERVERS_LIST="root@192.168.1.101,root@192.168.1.102,ubuntu@staging-server"
Run commands:

```bash
devopsctl remote
Test Setup (Docker)
```
If you want to test multi-server orchestration locally:

```bash
# Start two containers
docker run -it --rm --name server1 ubuntu:22.04 bash
docker run -it --rm --name server2 ubuntu:22.04 bash

# Install SSH on both containers
apt update && apt install -y openssh-server
echo "root:devops123" | chpasswd
service ssh start

# Get IP addresses
hostname -I

# Update config with the IPs
echo 'SERVERS_LIST="root@<ip1>,root@<ip2>"' > config/settings.conf

# Test
devopsctl remote
```
## 🛡️ Safety System
devopsctl includes safety features to protect your servers:

Feature	Description
Safe Mode	Prevents accidental destructive actions
Confirmations	Always asks "y/N" before risky operations
Rollback System	Every deployment creates a backup snapshot
Error Handling	All failures are logged with meaningful messages
--force Flag	Bypass confirmations when you're sure
```bash
# Normal operation (asks for confirmation)
devopsctl clean

# Force operation (skips confirmation)
devopsctl clean --force
```
## 📂 Project Structure
text
devopsctl/
├── devopsctl              # Main executable
├── auto-install.sh        # Zero-touch installer
├── install.sh             # Standard installer
├── config/
│   └── settings.conf      # User configuration
├── lib/
│   └── common.sh          # Core functions (colors, logging, safety)
├── modules/
│   ├── setup.sh           # Server provisioning
│   ├── deploy.sh          # Deployment & rollback
│   ├── monitor.sh         # System health
│   ├── docker.sh          # Container management
│   ├── backup.sh          # Backup & restore
│   ├── secure.sh          # Security hardening
│   ├── logs.sh            # Log viewer
│   ├── clean.sh           # System cleanup
│   ├── report.sh          # Audit reports
│   └── remote.sh          # Multi-server orchestration
└── logs/
    └── devopsctl.log      # Auto-generated audit log
    
## 🧪 Testing on Different Platforms
### ✅ Linux (Full Support)
All features work natively.

### ✅ macOS (Most Features)
Monitor, Report, Clean, Backup, Deploy work

Secure module (UFW, Fail2Ban) requires Linux

### ✅ Windows (Git Bash)
Monitor, Report, Clean, Backup work

Deploy works with Git installed

Secure requires WSL or Docker

### 🐳 Docker Testing
For full Linux testing on Windows:

```bash
docker run -it --rm -v ~/devopsctl:/app ubuntu:22.04 bash
cd /app
apt update && apt install -y sudo curl git systemctl iproute2 procps ufw fail2ban bc
./devopsctl monitor
./devopsctl report
./devopsctl secure --force
```
## 🔧 Troubleshooting
Command not found after installation
Open a new terminal or run:

```bash
source ~/.bashrc
```
### Permission denied
```bash
chmod +x ~/devopsctl/devopsctl
```
### Line endings errors on Windows (CRLF)

Fix all files:

```bash
cd ~/devopsctl
sed -i 's/\r$//' devopsctl
sed -i 's/\r$//' modules/*.sh
sed -i 's/\r$//' lib/*.sh
sed -i 's/\r$//' config/settings.conf
```
### SSH connection refused
```bash
# On the target server
systemctl status ssh
service ssh start
```
## 📊 Logging
All actions are logged to:
```bash
text
~/devopsctl/logs/devopsctl.log
```
View logs:

```bash
devopsctl logs
```
## 📄 License
This project is licensed under the MIT License – you are free to use, modify, and sell it commercially.

## 👨‍💻 Author
## Developed by MK youcef

Passionate DevOps engineer automating the world, one Bash script at a time.

GitHub: JerAxer

## ⭐ Show Your Support
If this toolkit saved you time or made your life easier, please give this repository a star ⭐ on GitHub! It helps others discover it.

### 📬 Contact & Support
### 🐛 Issues: https://github.com/JerAxer/devopsctl/issues

### 💬 Discussions: https://github.com/JerAxer/devopsctl/discussions

Happy DevOps-ing! 🚀
