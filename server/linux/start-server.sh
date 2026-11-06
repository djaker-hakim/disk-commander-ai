#!/usr/bin/env bash
# Starts the local llama.cpp server on Linux/macOS.
# Windows equivalent: launch-server.ps1 / start-server.bat

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"          # server/linux
SERVER_DIR="$(dirname "$SCRIPT_DIR")"                # server/
MODEL_PATH="$SERVER_DIR/models/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
# Look for llama-server binary in this platform's bin/ or in PATH
LLAMA_SERVER=""
if [ -x "$SCRIPT_DIR/bin/llama-server" ]; then
    LLAMA_SERVER="$SCRIPT_DIR/bin/llama-server"
elif command -v llama-server >/dev/null 2>&1; then
    LLAMA_SERVER="llama-server"
fi

PORT=8090
CTX_SIZE=8192
ALIAS="qwen3-4b-instruct"

if [ ! -f "$MODEL_PATH" ]; then
    echo "ERROR: Model missing at $MODEL_PATH" >&2
    echo "Run ./download-model.sh first." >&2
    exit 1
fi

if [ -z "$LLAMA_SERVER" ]; then
    echo "ERROR: llama-server binary not found in bin/ or on PATH." >&2
    echo "Place llama-server in server/bin/ or install llama.cpp." >&2
    exit 1
fi

# Check if port is already in use
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :$PORT -t >/dev/null 2>&1; then
        echo "ERROR: Port $PORT is already in use." >&2
        exit 1
    fi
fi

echo "============================================"
echo "  Starting local llama.cpp server (Linux)"
echo "  Model : $MODEL_PATH"
echo "  Alias : $ALIAS"
echo "  Port  : $PORT"
echo "  Stop  : Ctrl+C"
echo "============================================"
echo

exec "$LLAMA_SERVER" \
    --model "$MODEL_PATH" \
    --alias "$ALIAS" \
    --host 127.0.0.1 \
    --port "$PORT" \
    --ctx-size "$CTX_SIZE" \
    --parallel 1 \
    --jinja \
    --cache-type-k q8_0 \
    --temp 0.2 \
    --no-warmup
