#!/bin/bash
# nightshift-run.sh — Starts an autonomous NightShift run
#
# Creates backup branch, sets environment, starts Claude headless
# with hooks, and the watchdog in the background.
#
# Usage:
#   nightshift-run.sh <project-path> [runbook-path]
#
# Prerequisites:
#   - claude CLI installed and authenticated
#   - Project has .git
#   - git status clean (no uncommitted changes)
#   - Runbook exists

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# --- Argument Parsing ---
if [[ $# -lt 1 ]]; then
    echo "Usage: nightshift-run.sh <project-path> [runbook-path]" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  nightshift-run.sh ./projects/my-project plans/nightshift-2026-04-16.md" >&2
    exit 1
fi

PROJECT_PATH="$(cd "$1" && pwd)"
RUNBOOK_PATH="${2:-}"
DATE=$(date +%Y-%m-%d)
PID_FILE="/tmp/nightshift.pid"
HEARTBEAT_FILE="/tmp/nightshift-heartbeat"
WATCHDOG_PID=""

# --- Helper ---
notify() {
    osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true
}

cleanup() {
    echo ""
    echo "=== NightShift Cleanup ==="

    # Stop watchdog
    if [[ -n "$WATCHDOG_PID" ]] && kill -0 "$WATCHDOG_PID" 2>/dev/null; then
        echo "Stopping watchdog (PID $WATCHDOG_PID)..."
        kill "$WATCHDOG_PID" 2>/dev/null || true
    fi

    # Remove PID file
    rm -f "$PID_FILE" "$HEARTBEAT_FILE"

    notify "NightShift" "Run finished: $(basename "$PROJECT_PATH")"
    echo "NightShift finished."
}
trap cleanup EXIT

# --- Pre-flight checks ---
echo "=== NightShift Pre-Flight Check ==="

# Claude CLI
if ! command -v claude &>/dev/null; then
    echo "ERROR: claude CLI not found" >&2
    exit 1
fi
echo "[OK] claude CLI found"

# Project directory
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "ERROR: Project directory '$PROJECT_PATH' does not exist" >&2
    exit 1
fi
echo "[OK] Project directory: $PROJECT_PATH"

# Git repo
if [[ ! -d "$PROJECT_PATH/.git" ]]; then
    echo "ERROR: '$PROJECT_PATH' is not a Git repository" >&2
    exit 1
fi
echo "[OK] Git repository found"

# Git status clean
cd "$PROJECT_PATH"
if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERROR: Uncommitted changes in '$PROJECT_PATH'" >&2
    echo "Please commit or stash first." >&2
    git status --short >&2
    exit 1
fi
echo "[OK] Git status clean"

# Find runbook
if [[ -z "$RUNBOOK_PATH" ]]; then
    # Find newest runbook in plans/
    RUNBOOK_PATH=$(ls -t "${WORKSPACE_ROOT}/plans/nightshift-"*.md 2>/dev/null | head -1)
    if [[ -z "$RUNBOOK_PATH" ]]; then
        echo "ERROR: No runbook specified and no nightshift-*.md found in plans/" >&2
        exit 1
    fi
fi

# Relative path → absolute path
if [[ ! "$RUNBOOK_PATH" = /* ]]; then
    RUNBOOK_PATH="${WORKSPACE_ROOT}/${RUNBOOK_PATH}"
fi

if [[ ! -f "$RUNBOOK_PATH" ]]; then
    echo "ERROR: Runbook '$RUNBOOK_PATH' not found" >&2
    exit 1
fi
echo "[OK] Runbook: $RUNBOOK_PATH"

# PID lock
if [[ -f "$PID_FILE" ]]; then
    existing_pid=$(cat "$PID_FILE")
    if kill -0 "$existing_pid" 2>/dev/null; then
        echo "ERROR: NightShift is already running (PID $existing_pid)" >&2
        exit 1
    else
        echo "[WARN] Orphaned PID file found, removing"
        rm -f "$PID_FILE"
    fi
fi

echo ""
echo "=== NightShift Setup ==="

# --- Git Branches ---
BACKUP_BRANCH="nightshift/${DATE}-backup"
WORK_BRANCH="nightshift/${DATE}"

# Backup branch (safety copy of current state)
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

if git show-ref --verify --quiet "refs/heads/${BACKUP_BRANCH}"; then
    echo "[WARN] Backup branch '${BACKUP_BRANCH}' already exists, skipping"
else
    git branch "$BACKUP_BRANCH"
    echo "[OK] Backup branch created: $BACKUP_BRANCH"
fi

# Work branch
if git show-ref --verify --quiet "refs/heads/${WORK_BRANCH}"; then
    echo "[WARN] Work branch '${WORK_BRANCH}' already exists, switching to it"
    git checkout "$WORK_BRANCH"
else
    git checkout -b "$WORK_BRANCH"
    echo "[OK] Work branch created: $WORK_BRANCH"
fi

# --- Environment ---
export NIGHTSHIFT_ACTIVE=1
export NIGHTSHIFT_PROJECT="$PROJECT_PATH"
export NIGHTSHIFT_RUNBOOK="$RUNBOOK_PATH"

# --- PID File ---
echo $$ > "$PID_FILE"

# --- Start watchdog ---
echo ""
echo "=== Starting watchdog ==="
"${SCRIPT_DIR}/nightshift-watchdog.sh" \
    --pid-file "$PID_FILE" \
    --heartbeat "$HEARTBEAT_FILE" \
    > /tmp/nightshift-watchdog.log 2>&1 &
WATCHDOG_PID=$!
echo "[OK] Watchdog started (PID $WATCHDOG_PID)"

# --- Initial heartbeat ---
date +%s > "$HEARTBEAT_FILE"

# --- Start Claude ---
echo ""
echo "=== NightShift Start ==="
echo "Project:  $PROJECT_PATH"
echo "Runbook:  $RUNBOOK_PATH"
echo "Branch:   $WORK_BRANCH"
echo "Backup:   $BACKUP_BRANCH"
echo "PID File: $PID_FILE"
echo "Watchdog: PID $WATCHDOG_PID"
echo ""
echo "Claude starting in autonomous mode..."
echo "Stop with: Ctrl+C"
echo "=========================================="
echo ""

notify "NightShift" "Started: $(basename "$PROJECT_PATH")"

# Claude headless with runbook prompt
claude -p "You are in nightshift mode (autonomous, without human-in-the-loop).

IMPORTANT — Read first:
1. The runbook: ${RUNBOOK_PATH}
2. The project CLAUDE.md (if available): ${PROJECT_PATH}/CLAUDE.md

Then:
- Work through all steps in the runbook sequentially
- Check off each step when completed (checkbox in runbook)
- Commit after each step: git commit -m 'nightshift: step N — [description]'
- Strictly follow the autonomy zones in the runbook
- Document decisions in the decision log
- Every 5 steps: Re-read the autonomy zones and the error budget
- On error exceeding error budget: STOP and write the summary
- At the end: Write the summary in the runbook (status, completed steps, open items)
- Final commit: git commit -m 'nightshift: run completed — [summary]'" \
    --dangerously-skip-permissions \
    2>&1 | tee /tmp/nightshift-output.log

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=== NightShift finished (Exit: $EXIT_CODE) ==="

if [[ $EXIT_CODE -eq 0 ]]; then
    notify "NightShift" "Successfully completed: $(basename "$PROJECT_PATH")"
else
    notify "NightShift" "Finished with error (Exit $EXIT_CODE): $(basename "$PROJECT_PATH")"
fi

exit $EXIT_CODE
