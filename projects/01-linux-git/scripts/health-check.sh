#!/bin/bash

set -euo pipefail

echo "=== System Health Report ==="

echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"

echo "CPU Load: $(cat /proc/loadavg | awk '{print $1,$2,$3}')"

echo "Memory: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"

echo "Disk: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5" used)"}')"

echo "==========================="
