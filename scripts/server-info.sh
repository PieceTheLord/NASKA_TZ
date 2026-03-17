#!/bin/bash

LOG_FILE="server_diagnostics.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Цвета для вывода (бонусное задание)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

show_help() {
    echo "Usage: $0 [URL1] [URL2] ..."
    echo "Diagnostics script to check system info and service health."
    echo ""
    echo "Options:"
    echo "  --help    Show this help message and exit"
}

log_and_print() {
    echo -e "$1"
    echo -e "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" >> "$LOG_FILE"
}

if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

echo "--- Diagnostics Run at $TIMESTAMP ---" >> "$LOG_FILE"

log_and_print "=== Server Diagnostics ==="
log_and_print "Date:     $TIMESTAMP"
log_and_print "Hostname: $(hostname)"
log_and_print "OS:       $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
log_and_print "Kernel:   $(uname -r)"
log_and_print "Uptime:   $(uptime -p)"
log_and_print ""

log_and_print "=== Resources ==="
log_and_print "CPU Load: $(uptime | awk -F'load average:' '{ print $2 }')"
log_and_print "RAM:      $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
log_and_print "Disk /:   $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
log_and_print ""

log_and_print "=== Docker ==="
if command -v docker &> /dev/null; then
    docker_ps=$(docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}")
    log_and_print "$docker_ps"
else
    log_and_print "Docker is not installed."
fi
log_and_print ""

# Проверка сервисов (аргументы)
FAILED_SERVICES=0
TOTAL_SERVICES=$#

if[ "$TOTAL_SERVICES" -gt 0 ]; then
    log_and_print "=== Service Health Checks ==="
    for url in "$@"; do
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
        if[ "$HTTP_CODE" -eq 200 ]; then
            log_and_print "[${GREEN}OK${NC}]   $url (HTTP $HTTP_CODE)"
        else
            log_and_print "[${RED}FAIL${NC}] $url (HTTP $HTTP_CODE or connection refused)"
            FAILED_SERVICES=$((FAILED_SERVICES + 1))
        fi
    done

    log_and_print ""
    HEALTHY=$((TOTAL_SERVICES - FAILED_SERVICES))
    log_and_print "Result: $HEALTHY/$TOTAL_SERVICES services healthy"

    if [ "$FAILED_SERVICES" -gt 0 ]; then
        exit 1
    fi
fi

exit 0