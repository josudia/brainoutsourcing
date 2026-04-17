#!/bin/bash
# nightshift-watchdog.sh — Heartbeat monitor for autonomous NightShift runs
#
# Monitors /tmp/nightshift-heartbeat and the Claude process.
# Warns via macOS notification on stall or crash.
#
# Usage:
#   nightshift-watchdog.sh [--timeout 600] [--interval 60] [--pid-file /tmp/nightshift.pid]

set -euo pipefail

# --- Defaults ---
WATCHDOG_TIMEOUT="${WATCHDOG_TIMEOUT:-600}"    # Seconds until stall warning (10 min)
WATCHDOG_INTERVAL="${WATCHDOG_INTERVAL:-60}"   # Check interval (1 min)
HEARTBEAT_FILE="/tmp/nightshift-heartbeat"
PID_FILE="/tmp/nightshift.pid"

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --timeout)   WATCHDOG_TIMEOUT="$2"; shift 2 ;;
        --interval)  WATCHDOG_INTERVAL="$2"; shift 2 ;;
        --pid-file)  PID_FILE="$2"; shift 2 ;;
        --heartbeat) HEARTBEAT_FILE="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --- Notification Helper ---
notify() {
    local title="$1"
    local message="$2"
    local subtitle="${3:-}"
    if [[ -n "$subtitle" ]]; then
        osascript -e "display notification \"${message}\" with title \"${title}\" subtitle \"${subtitle}\""
    else
        osascript -e "display notification \"${message}\" with title \"${title}\""
    fi
    # Terminal bell as backup
    printf '\a'
}

# --- Graceful Shutdown ---
cleanup() {
    echo "[watchdog] Stopped ($(date '+%H:%M:%S'))"
    exit 0
}
trap cleanup SIGTERM SIGINT

# --- Main Loop ---
echo "[watchdog] Started — Timeout: ${WATCHDOG_TIMEOUT}s, Interval: ${WATCHDOG_INTERVAL}s"
echo "[watchdog] Heartbeat: ${HEARTBEAT_FILE}, PID: ${PID_FILE}"

stall_notified=false

while true; do
    now=$(date +%s)

    # 1. Check if Claude process is still running
    if [[ -f "$PID_FILE" ]]; then
        claude_pid=$(cat "$PID_FILE")
        if ! kill -0 "$claude_pid" 2>/dev/null; then
            echo "[watchdog] Claude process (PID $claude_pid) no longer active"
            notify "NightShift" "Claude process terminated (PID $claude_pid)" "Run completed or crashed"
            exit 0
        fi
    fi

    # 2. Check heartbeat
    if [[ -f "$HEARTBEAT_FILE" ]]; then
        last_beat=$(cat "$HEARTBEAT_FILE")
        delta=$((now - last_beat))

        if [[ $delta -gt $WATCHDOG_TIMEOUT ]]; then
            if [[ "$stall_notified" == "false" ]]; then
                echo "[watchdog] STALL detected — last activity ${delta}s ago"
                notify "NightShift" "No activity for ${delta} seconds" "Stall detected"
                stall_notified=true
            fi
        else
            if [[ "$stall_notified" == "true" ]]; then
                echo "[watchdog] Activity detected again"
                stall_notified=false
            fi
            echo "[watchdog] OK — last activity ${delta}s ago ($(date '+%H:%M:%S'))"
        fi
    else
        echo "[watchdog] No heartbeat file found — waiting... ($(date '+%H:%M:%S'))"
    fi

    sleep "$WATCHDOG_INTERVAL"
done
