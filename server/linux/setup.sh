#!/usr/bin/env bash
# Downloads llama.cpp (Linux x64 build) and the Qwen3-4B-Instruct-2507
# GGUF model into bin/linux and models/.
# Windows equivalent: setup.ps1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"        # server/linux
SERVER_DIR="$(dirname "$SCRIPT_DIR")"              # server/
BIN_DIR="$SCRIPT_DIR/bin"
MODELS_DIR="$SERVER_DIR/models"
MODEL_NAME="Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
MODEL_URL="https://huggingface.co/bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF/resolve/main/$MODEL_NAME"

fetch() { # fetch <url> <out>
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -L --fail --retry 3 -C - -o "$out" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -c -O "$out" "$url"
    else
        echo "DOWNLOAD_FAILED: need curl or wget" >&2
        exit 1
    fi
}

echo "=== AI Models USB setup (Linux) ==="
mkdir -p "$BIN_DIR" "$MODELS_DIR"

# --- 1. llama.cpp -----------------------------------------------------------
if [ -x "$BIN_DIR/llama-server" ]; then
    echo "[1/2] llama.cpp already present."
else
    echo "[1/2] Resolving latest llama.cpp Linux build..."
    for rel in $(curl -fsSL -H 'User-Agent: opencode' \
        'https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=15' \
        | grep -Eo '"browser_download_url": *"[^"]*llama-[^"]*-bin-ubuntu-x64\.tar\.gz"' \
        | sed 's/.*"https:/https:/; s/"$//'); do
        URL="$rel"
        break
    done
    if [ -z "${URL:-}" ]; then
        echo "No ubuntu-x64 asset found in recent llama.cpp releases." >&2
        exit 1
    fi

    TGZ="$SCRIPT_DIR/llama.tar.gz"
    echo "  Downloading $URL ..."
    fetch "$URL" "$TGZ"

    echo "  Extracting..."
    tar -xzf "$TGZ" -C "$BIN_DIR" --strip-components=1
    rm -f "$TGZ"
    chmod +x "$BIN_DIR"/llama-* 2>/dev/null || true

    if [ -x "$BIN_DIR/llama-server" ]; then
        echo "[1/2] llama.cpp ready."
    else
        echo "llama-server not found after extraction." >&2
        exit 1
    fi
fi

# --- 2. Model ---------------------------------------------------------------
if [ -s "$MODELS_DIR/$MODEL_NAME" ]; then
    echo "[2/2] Model already present."
else
    echo "[2/2] Downloading $MODEL_NAME (~2.5 GB) ..."
    fetch "$MODEL_URL" "$MODELS_DIR/$MODEL_NAME"
    echo "[2/2] Model ready."
fi

echo
echo "=== Done ==="
echo "Model : $MODELS_DIR/$MODEL_NAME"
echo "Bin   : $BIN_DIR"
echo "Start the server with: ./start-server.sh"
