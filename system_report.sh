#!/bin/bash

LOG_FILE="/var/log/system_report.log"

{
  echo "==============================="
  echo "System Report - $(date)"
  echo "-------------------------------"
  echo "Uptime:"
  uptime

  echo
  echo "CPU usage (%):"
  mpstat 1 1 | awk '/Average/ && $3 ~ /CPU/ {next} /Average/ {print 100-$13"%"}'

  echo
  echo "Memory usage (%):"
  free | awk '/Mem:/ {printf("%.2f%\n", $3/$2 * 100)}'

  echo
  echo "Disk usage (%):"
  df -h / | awk 'NR==2 {print $5}'

  echo
  echo "Top 3 processes by CPU usage:"
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 4

  echo
} >> "$LOG_FILE"
# --- Disk usage alert section ---
DISK_USAGE_PERCENT=$(df -h / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
THRESHOLD=80

if [ "$DISK_USAGE_PERCENT" -gt "$THRESHOLD" ]; then
  ALERT_SUBJECT="High Disk Usage on $(hostname) - ${DISK_USAGE_PERCENT}%"
  ALERT_BODY="Warning: Disk usage on $(hostname) has reached ${DISK_USAGE_PERCENT}%.
Current value: ${DISK_USAGE_PERCENT}%
Log file: /var/log/system_report.log
Time: $(date)"

  echo "$ALERT_BODY" | mail -s "$ALERT_SUBJECT" nikhilmaradani71@gmail.com
fi
