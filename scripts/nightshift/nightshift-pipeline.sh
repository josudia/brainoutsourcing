#!/bin/bash
# nightshift-pipeline.sh — Task queue runner for NightShift
#
# Polls the Apple Reminders "Nightshift" list and processes tasks sequentially.
# Each task gets a fresh Claude session (no context rot).
# Tasks must reference a project under projects/.
#
# Usage:
#   nightshift-pipeline.sh [--poll-interval 60] [--max-task-minutes 30] [--idle-after 3]
#
# Reminder convention:
#   Title: Task description
#   Notes: Project path (absolute or relative to workspace/projects/) + Details

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BRIDGE="${WORKSPACE_ROOT}/scripts/reminders/reminders-bridge.sh"
RUNNER="${SCRIPT_DIR}/nightshift-run.sh"

# Nightshift Reminders List-ID (run `reminders-bridge.sh list-all` to find yours)
NIGHTSHIFT_LIST_ID="${BRAINOUTSOURCING_NIGHTSHIFT_LIST_ID:-}"

# --- Defaults ---
POLL_INTERVAL="${POLL_INTERVAL:-60}"
MAX_TASK_MINUTES="${MAX_TASK_MINUTES:-30}"
IDLE_AFTER="${IDLE_AFTER:-3}"

PID_FILE="/tmp/nightshift-pipeline.pid"
LOG_FILE="/tmp/nightshift-pipeline.log"
TASK_COUNT=0
IDLE_COUNT=0

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --poll-interval)    POLL_INTERVAL="$2"; shift 2 ;;
        --max-task-minutes) MAX_TASK_MINUTES="$2"; shift 2 ;;
        --idle-after)       IDLE_AFTER="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# --- Helper ---
notify() {
    osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true
}

log() {
    echo "[pipeline $(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cleanup() {
    log "Pipeline finished (${TASK_COUNT} tasks completed)"
    rm -f "$PID_FILE"
    notify "NightShift Pipeline" "Finished — ${TASK_COUNT} tasks completed"
    exit 0
}
trap cleanup SIGTERM SIGINT EXIT

# --- PID Lock ---
if [[ -f "$PID_FILE" ]]; then
    existing_pid=$(cat "$PID_FILE")
    if kill -0 "$existing_pid" 2>/dev/null; then
        echo "ERROR: Pipeline is already running (PID $existing_pid)" >&2
        exit 1
    fi
    rm -f "$PID_FILE"
fi
echo $$ > "$PID_FILE"

# --- Start ---
log "Pipeline started — Poll: ${POLL_INTERVAL}s, Max: ${MAX_TASK_MINUTES}min, Idle-Stop: after ${IDLE_AFTER} empty polls"
notify "NightShift Pipeline" "Started — polling Nightshift list"

# --- Poll Loop ---
while true; do
    # Read reminders (tab-separated: name, id, notes, due, priority)
    TASKS=$("$BRIDGE" list "$NIGHTSHIFT_LIST_ID" 2>/dev/null || echo "")

    if [[ -z "$TASKS" || "$TASKS" == *"missing value"* && ${#TASKS} -lt 10 ]]; then
        # No tasks
        IDLE_COUNT=$((IDLE_COUNT + 1))
        log "Queue empty (idle ${IDLE_COUNT}/${IDLE_AFTER})"

        if [[ $IDLE_COUNT -ge $IDLE_AFTER ]]; then
            log "Idle limit reached — pipeline stopping"
            exit 0
        fi

        sleep "$POLL_INTERVAL"
        continue
    fi

    # Reset idle counter
    IDLE_COUNT=0

    # Take first task (oldest = first line)
    FIRST_TASK=$(echo "$TASKS" | head -1)
    TASK_NAME=$(echo "$FIRST_TASK" | cut -f1)
    TASK_ID=$(echo "$FIRST_TASK" | cut -f2)
    TASK_NOTES=$(echo "$FIRST_TASK" | cut -f3)
    TASK_DUE=$(echo "$FIRST_TASK" | cut -f4)

    log "Task found: '${TASK_NAME}'"
    log "  Notes: ${TASK_NOTES:-none}"

    # Extract project path from notes
    # Expected: first line = project path, rest = details
    PROJECT_PATH=""
    TASK_DETAILS=""
    if [[ -n "$TASK_NOTES" && "$TASK_NOTES" != "missing value" ]]; then
        # Try first line as project path
        FIRST_LINE=$(echo "$TASK_NOTES" | head -1)
        REMAINING=$(echo "$TASK_NOTES" | tail -n +2)

        # Use absolute paths directly
        if [[ "$FIRST_LINE" == /* ]]; then
            PROJECT_PATH="$FIRST_LINE"
            TASK_DETAILS="$REMAINING"
        # Look for relative paths under projects/
        elif [[ -d "${WORKSPACE_ROOT}/projects/${FIRST_LINE}" ]]; then
            PROJECT_PATH="${WORKSPACE_ROOT}/projects/${FIRST_LINE}"
            TASK_DETAILS="$REMAINING"
        else
            # No path line recognized — treat everything as details
            TASK_DETAILS="$TASK_NOTES"
        fi
    fi

    # Fallback: derive project name from task title
    if [[ -z "$PROJECT_PATH" ]]; then
        # Try [project] prefix
        if [[ "$TASK_NAME" =~ ^\[([^\]]+)\] ]]; then
            PROJ_NAME="${BASH_REMATCH[1]}"
            if [[ -d "${WORKSPACE_ROOT}/projects/${PROJ_NAME}" ]]; then
                PROJECT_PATH="${WORKSPACE_ROOT}/projects/${PROJ_NAME}"
            fi
        fi
    fi

    if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
        log "ERROR: No valid project path for '${TASK_NAME}'"
        log "  Expected project path in first line of reminder notes"
        log "  Or [projectname] prefix in title"
        # Do not mark task as failed — user should add the path
        notify "NightShift" "No project path for: ${TASK_NAME}"
        sleep "$POLL_INTERVAL"
        continue
    fi

    if [[ ! -d "$PROJECT_PATH/.git" ]]; then
        log "ERROR: '${PROJECT_PATH}' is not a Git repository"
        notify "NightShift" "No Git repo: ${PROJECT_PATH}"
        sleep "$POLL_INTERVAL"
        continue
    fi

    log "Project: ${PROJECT_PATH}"

    # Generate runbook (simple version via Claude)
    DATE=$(date +%Y-%m-%d)
    TASK_NUM=$((TASK_COUNT + 1))
    RUNBOOK_PATH="${WORKSPACE_ROOT}/plans/nightshift-pipeline-${DATE}-$(printf '%03d' $TASK_NUM).md"

    log "Generating runbook: ${RUNBOOK_PATH}"

    # Claude generates runbook
    claude -p "Create a NightShift runbook for the following task.

Task: ${TASK_NAME}
Project path: ${PROJECT_PATH}
Details: ${TASK_DETAILS:-no further details}

Use the template from: ${WORKSPACE_ROOT}/scripts/nightshift/templates/runbook-template.md
Read the project CLAUDE.md: ${PROJECT_PATH}/CLAUDE.md (if available)

Fill in all placeholders. Write the finished runbook to: ${RUNBOOK_PATH}

Important:
- 5-20 concrete steps with file paths
- No vague steps
- No git push
- Realistic autonomy zones
- Define error budget" \
        --dangerously-skip-permissions \
        > /tmp/nightshift-runbook-gen.log 2>&1

    if [[ ! -f "$RUNBOOK_PATH" ]]; then
        log "ERROR: Runbook could not be generated"
        notify "NightShift" "Runbook error for: ${TASK_NAME}"
        sleep "$POLL_INTERVAL"
        continue
    fi

    # Start run (with timeout)
    log "Starting run: ${TASK_NAME} (Timeout: ${MAX_TASK_MINUTES}min)"

    timeout_seconds=$((MAX_TASK_MINUTES * 60))

    if timeout "$timeout_seconds" "$RUNNER" "$PROJECT_PATH" "$RUNBOOK_PATH" \
        >> /tmp/nightshift-pipeline-task.log 2>&1; then
        # Success
        log "Task successful: '${TASK_NAME}'"
        "$BRIDGE" complete "$NIGHTSHIFT_LIST_ID" "$TASK_NAME" 2>/dev/null || true
        notify "NightShift" "Completed: ${TASK_NAME}"
        TASK_COUNT=$((TASK_COUNT + 1))
    else
        EXIT_CODE=$?
        if [[ $EXIT_CODE -eq 124 ]]; then
            log "Task timeout (${MAX_TASK_MINUTES}min): '${TASK_NAME}'"
            notify "NightShift" "Timeout: ${TASK_NAME}"
        else
            log "Task failed (Exit $EXIT_CODE): '${TASK_NAME}'"
            notify "NightShift" "Failed: ${TASK_NAME}"
        fi
        # Do NOT mark task as complete — stays in the list
    fi

    # Short pause between tasks
    sleep 5
done
