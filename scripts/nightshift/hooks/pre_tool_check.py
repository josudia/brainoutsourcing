#!/usr/bin/env python3
"""PreToolUse Hook — blocks destructive commands.

Called by Claude Code as a PreToolUse hook.
Input: JSON on stdin (Claude Code hook protocol).
Exit 0 = allowed, Exit 2 = blocked (unconditional block).

In nightshift mode ($NIGHTSHIFT_ACTIVE=1): additional restrictions.
"""

import json
import os
import re
import sys

# --- Blocklists ---

ALWAYS_BLOCK = [
    (r"rm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+/", "rm -rf /"),
    (r"rm\s+-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*\s+/", "rm -fr /"),
    (r"sudo\s+", "sudo"),
    (r"chmod\s+777", "chmod 777"),
    (r"mkfs\.", "mkfs"),
    (r"\bdd\b\s+if=", "dd"),
    (r"curl.*\|\s*(ba)?sh", "curl | bash"),
    (r"wget.*\|\s*(ba)?sh", "wget | bash"),
    (r":\s*\(\s*\)\s*\{.*\}", "fork bomb"),
    (r">\s*/dev/sd", "write to disk device"),
    (r"\beval\s+", "eval"),
]

NIGHTSHIFT_BLOCK = [
    (r"git\s+push", "git push"),
    (r"curl\s+.*-X\s*POST", "HTTP POST"),
    (r"curl\s+.*--data", "HTTP POST (--data)"),
    (r"ssh\s+", "ssh"),
    (r"scp\s+", "scp"),
]


def check_command(command: str) -> tuple[bool, str]:
    """Check a command against blocklists. Returns (blocked, reason)."""
    # Always-block patterns
    for pattern, name in ALWAYS_BLOCK:
        if re.search(pattern, command):
            return True, f"BLOCKED: '{name}' is not allowed"

    # Nightshift-mode additional blocks
    if os.environ.get("NIGHTSHIFT_ACTIVE") == "1":
        for pattern, name in NIGHTSHIFT_BLOCK:
            if re.search(pattern, command):
                return True, f"BLOCKED (nightshift): '{name}' is not allowed in autonomous mode"

        # Path restriction: block access outside project root
        project_root = os.environ.get("NIGHTSHIFT_PROJECT", "")
        if project_root:
            # Check for absolute paths that are outside project
            abs_paths = re.findall(r"(?:^|\s)(/[^\s]+)", command)
            allowed_prefixes = [project_root, "/tmp", "/dev/null", "/usr", "/bin", "/opt"]
            for path in abs_paths:
                if not any(path.startswith(prefix) for prefix in allowed_prefixes):
                    return True, f"BLOCKED (nightshift): path '{path}' is outside project root '{project_root}'"

    return False, ""


def main():
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        # Can't parse input — allow (fail open for non-Bash tools)
        sys.exit(0)

    tool_name = hook_input.get("tool_name", "")

    # Only check Bash commands
    if tool_name != "Bash":
        sys.exit(0)

    tool_input = hook_input.get("tool_input", {})
    command = tool_input.get("command", "")

    if not command:
        sys.exit(0)

    blocked, reason = check_command(command)

    if blocked:
        # Exit 2 = unconditional block (Claude Code convention)
        print(reason, file=sys.stderr)
        sys.exit(2)

    # Allowed
    sys.exit(0)


if __name__ == "__main__":
    main()
