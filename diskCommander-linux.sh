#!/usr/bin/env bash
# diskCommander - one-click launcher (Linux).
# Windows equivalent: diskCommander.bat
#
# 1. Reuses the llama.cpp server if it's already running on port 8090,
#    otherwise starts it in the background with a log file.
# 2. Launches OpenCode in the workspace.
# 3. On exit, asks whether to stop the server too.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/server/server.pid"
LOG_FILE="$SCRIPT_DIR/server/server.log"
HEALTH_URL="http://127.0.0.1:8090/health"

health_ok() {
    curl -s --max-time 3 "$HEALTH_URL" 2>/dev/null | grep -qi ok
}

echo "=============================================="
echo "  diskCommander"
echo "  One click: llama.cpp server + OpenCode"
echo "=============================================="
echo

# ---- 1. Reuse the server if it is already running ---------------------------
if health_ok; then
    echo "[1/2] Server already running on port 8090 - reusing it."
else
    echo "[1/2] Starting llama.cpp server in the background..."

    bash "$SCRIPT_DIR/server/linux/start-server.sh" >"$LOG_FILE" 2>&1 &
    if [ $? -ne 0 ]; then
        echo "ERROR: could not start server - see $LOG_FILE" >&2
        exit 1
    fi
    echo $! > "$PID_FILE"
    echo "      Waiting for the model to load... (log: $LOG_FILE)"

    tries=0
    until health_ok; do
        sleep 2
        tries=$((tries + 1))
        if [ "$tries" -ge 90 ]; then
            echo
            echo "WARNING: server not ready after 3 minutes - starting OpenCode anyway."
            echo "         Check $LOG_FILE for errors."
            break
        fi
    done
fi

# ---- 2. Start OpenCode in the workspace ------------------------------------
echo "[2/2] Starting OpenCode in the workspace..."
echo
bash "$SCRIPT_DIR/opencode/linux/start-opencode.sh" "$@"
exitcode=$?

echo
echo "OpenCode closed (exit code: $exitcode)."
read -r -p "Stop the llama.cpp server too? [Y/n] " answer
case "$answer" in
    [nN]*)
        echo "Server still running in the background - stop it with:"
        echo "  kill \$(cat $PID_FILE)"
        ;;
    *)
        echo "Stopping server..."
        if [ -f "$PID_FILE" ]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null
            rm -f "$PID_FILE"
        else
            # Server was started elsewhere; stop it by port.
            if command -v fuser >/dev/null 2>&1; then
                fuser -k 8090/tcp 2>/dev/null
            elif command -v lsof >/dev/null 2>&1; then
                lsof -ti :8090 | xargs -r kill
            fi
        fi
        echo "Done."
        ;;
esac
exit "$exitcode"
