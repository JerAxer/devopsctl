# 🚀 devopsctl – DevOps Toolkit CLI

> **A production-grade, modular CLI tool to manage servers, deploy apps, monitor resources, and generate audit reports—all from a single command.**

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/devopsctl)
[![Bash](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

**Developed with ❤️ by [MK youcef](https://github.com/JerAxer)**

---

## 📖 Overview

`devopsctl` is a **sellable, production-ready DevOps automation product** for Linux servers (and fully functional on macOS/Windows via Git Bash). It combines server provisioning, application deployment with instant rollback, real-time monitoring, security hardening, and multi-server orchestration into one elegant CLI.

Whether you are managing 1 server or 100, `devopsctl` gives you the power of a senior DevOps engineer in your terminal.

---

## ✨ Features

| Module | Description |
| :--- | :--- |
| **⚙️ Setup** | Installs Docker, Nginx, Git, and dependencies automatically. |
| **🚀 Deploy** | Git-based deployment with automatic build detection (Node/Python) and **one-command rollback**. |
| **📊 Monitor** | Real-time CPU, RAM, Disk usage with threshold alerts. |
| **🐳 Docker** | Manage containers, build images, and prune unused resources. |
| **💾 Backup** | Compressed folder backups + MySQL/PostgreSQL database dumps with versioning. |
| **🔐 Security** | UFW firewall configuration, Fail2Ban setup, and SSH hardening. |
| **📡 Logs** | Color-coded log viewer with automatic error detection. |
| **🧹 Clean** | Safe system cleanup (cache, Docker garbage, old logs). |
| **📄 Report** | Generates beautiful **HTML & TXT** system audit reports. |
| **🌐 Remote** | Execute any command across **multiple servers** simultaneously via SSH. |

---

## 🛠️ Quick Install (One-Liner)

Just copy and paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/devopsctl/main/auto-install.sh | bash