#!/usr/bin/env bash
# Starts OpenCode on Linux/macOS using the local workspace.
# Windows equivalent: start-opencode.bat

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="$(dirname "$SCRIPT_DIR")"        # opencode/
ROOT_DIR="$(dirname "$OPENCODE_DIR")"          # repo root
WORKSPACE_DIR="$ROOT_DIR/workspace"

# Locate opencode binary
OPENCODE_BIN=""
if [ -n "${OPENCODE_EXE:-}" ] && [ -x "$OPENCODE_EXE" ]; then
    OPENCODE_BIN="$OPENCODE_EXE"
elif [ -x "$SCRIPT_DIR/opencode" ]; then
    OPENCODE_BIN="$SCRIPT_DIR/opencode"
elif command -v opencode >/dev/null 2>&1; then
    OPENCODE_BIN="opencode"
elif [ -x "$HOME/.opencode/bin/opencode" ]; then
    OPENCODE_BIN="$HOME/.opencode/bin/opencode"
else
    echo "ERROR: opencode binary not found." >&2
    echo "Place opencode in opencode/, add it to PATH, or set OPENCODE_EXE=/path/to/opencode" >&2
    exit 1
fi

mkdir -p "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"

# Seed live config if missing
if [ ! -f "opencode.json" ]; then
    cp "$SCRIPT_DIR/opencode.example.json" "opencode.json"
    echo "Created opencode.json from opencode.example.json"
# Repair a config seeded on Windows (powershell agent): use the Linux one.
elif grep -q '"powershell"' "opencode.json" && ! grep -q '"bash"' "opencode.json"; then
    cp "$SCRIPT_DIR/opencode.example.json" "opencode.json"
    echo "Replaced Windows (powershell) config with the Linux version"
fi

echo "Working directory: $(pwd)"
echo "Using OpenCode: $OPENCODE_BIN"
echo
echo "Agents: bash  (default - shell only)"
echo "        files (read/write only, no shell)"
echo
echo "  start-opencode.sh                   - bash agent"
echo "  start-opencode.sh --agent files     - file agent"
echo

exec "$OPENCODE_BIN" "$@"
