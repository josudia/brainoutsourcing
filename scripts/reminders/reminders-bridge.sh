#!/bin/bash
# reminders-bridge.sh — AppleScript wrapper for Apple Reminders
# Addresses lists via UUIDs (not names) to avoid duplicates.
# Optional: syncs via CalDAV (iPhone ↔ Mac).
# Run `reminders-bridge.sh list-all` to find your List IDs.
#
# Usage:
#   reminders-bridge.sh list-all
#   reminders-bridge.sh list <list-id>
#   reminders-bridge.sh count <list-id>
#   reminders-bridge.sh create <list-id> <title> [--notes "..."] [--due "YYYY-MM-DD"]
#   reminders-bridge.sh complete <list-id> <reminder-name>

set -euo pipefail

# --- Known List IDs (run `list-all` to find yours) ---
AUFGABEN_LIST_ID="${BRAINOUTSOURCING_TASKS_LIST_ID:-}"
NIGHTSHIFT_LIST_ID="${BRAINOUTSOURCING_NIGHTSHIFT_LIST_ID:-}"

# --- Helper ---
ensure_reminders_running() {
    if ! pgrep -q "Reminders"; then
        open -gja "Reminders"
        sleep 1
    fi
}

# --- Subcommands ---

cmd_list_all() {
    ensure_reminders_running
    osascript << 'APPLESCRIPT'
tell application "Reminders"
    set output to ""
    repeat with aList in every list
        set listName to name of aList
        set listId to id of aList
        try
            set acctName to name of container of aList
        on error
            set acctName to "unknown"
        end try
        set remCount to count of (reminders of aList whose completed is false)
        set output to output & listId & "	" & listName & "	" & acctName & "	" & remCount & linefeed
    end repeat
    return output
end tell
APPLESCRIPT
}

cmd_list() {
    local list_id="$1"
    ensure_reminders_running
    osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set openReminders to (every reminder of targetList whose completed is false)
    set output to ""
    repeat with r in openReminders
        set rName to name of r
        set rId to id of r
        try
            set rBody to body of r
            if rBody is missing value then set rBody to ""
        on error
            set rBody to ""
        end try
        try
            set rDue to due date of r as string
        on error
            set rDue to ""
        end try
        set rPrio to priority of r as integer
        -- Tab-separated: name, id, notes, due, priority
        set output to output & rName & "	" & rId & "	" & rBody & "	" & rDue & "	" & rPrio & linefeed
    end repeat
    return output
end tell
APPLESCRIPT
}

cmd_count() {
    local list_id="$1"
    ensure_reminders_running
    osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    return count of (reminders of targetList whose completed is false)
end tell
APPLESCRIPT
}

cmd_create() {
    local list_id="$1"
    local title="$2"
    shift 2
    local notes=""
    local due=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --notes) notes="$2"; shift 2 ;;
            --due)   due="$2"; shift 2 ;;
            *) echo "Unknown option: $1" >&2; exit 1 ;;
        esac
    done

    ensure_reminders_running

    if [[ -n "$due" && -n "$notes" ]]; then
        osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set dueStr to "${due}"
    set dueDate to date dueStr
    set newReminder to make new reminder at end of targetList with properties {name:"${title}", body:"${notes}", due date:dueDate}
    return "created: " & name of newReminder
end tell
APPLESCRIPT
    elif [[ -n "$notes" ]]; then
        osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set newReminder to make new reminder at end of targetList with properties {name:"${title}", body:"${notes}"}
    return "created: " & name of newReminder
end tell
APPLESCRIPT
    elif [[ -n "$due" ]]; then
        osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set dueStr to "${due}"
    set dueDate to date dueStr
    set newReminder to make new reminder at end of targetList with properties {name:"${title}", due date:dueDate}
    return "created: " & name of newReminder
end tell
APPLESCRIPT
    else
        osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set newReminder to make new reminder at end of targetList with properties {name:"${title}"}
    return "created: " & name of newReminder
end tell
APPLESCRIPT
    fi
}

cmd_complete() {
    local list_id="$1"
    local reminder_name="$2"
    ensure_reminders_running
    osascript << APPLESCRIPT
tell application "Reminders"
    set targetList to list id "${list_id}"
    set matchingReminders to (every reminder of targetList whose name is "${reminder_name}" and completed is false)
    if (count of matchingReminders) is 0 then
        return "error: no incomplete reminder found with name '${reminder_name}'"
    end if
    set theReminder to item 1 of matchingReminders
    set completed of theReminder to true
    return "completed: " & name of theReminder
end tell
APPLESCRIPT
}

# --- Main ---

if [[ $# -lt 1 ]]; then
    echo "Usage: reminders-bridge.sh <command> [args...]" >&2
    echo "" >&2
    echo "Commands:" >&2
    echo "  list-all                          List all reminder lists with IDs" >&2
    echo "  list <list-id>                    List open reminders in a list" >&2
    echo "  count <list-id>                   Count open reminders" >&2
    echo "  create <list-id> <title> [opts]   Create a reminder (--notes, --due)" >&2
    echo "  complete <list-id> <name>         Mark reminder as done" >&2
    echo "" >&2
    echo "Known List IDs:" >&2
    echo "  Aufgaben:   $AUFGABEN_LIST_ID" >&2
    echo "  Nightshift: $NIGHTSHIFT_LIST_ID" >&2
    exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
    list-all)
        cmd_list_all
        ;;
    list)
        [[ $# -lt 1 ]] && { echo "Usage: reminders-bridge.sh list <list-id>" >&2; exit 1; }
        cmd_list "$1"
        ;;
    count)
        [[ $# -lt 1 ]] && { echo "Usage: reminders-bridge.sh count <list-id>" >&2; exit 1; }
        cmd_count "$1"
        ;;
    create)
        [[ $# -lt 2 ]] && { echo "Usage: reminders-bridge.sh create <list-id> <title> [--notes ...] [--due ...]" >&2; exit 1; }
        cmd_create "$@"
        ;;
    complete)
        [[ $# -lt 2 ]] && { echo "Usage: reminders-bridge.sh complete <list-id> <reminder-name>" >&2; exit 1; }
        cmd_complete "$1" "$2"
        ;;
    *)
        echo "Unknown command: $COMMAND" >&2
        exit 1
        ;;
esac
