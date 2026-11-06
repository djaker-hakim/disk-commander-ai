#!/usr/bin/env bash
# Downloads llama.cpp (Linux x64 build) and the Qwen3-4B-Instruct-2507
# GGUF model into bin/ and models/.
# Windows equivalent: setup.ps1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
MODELS_DIR="$SCRIPT_DIR/models"
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
    echo "[1/2] Resolving latest llama.cpp Linux release..."
    JSON="$(curl -fsSL -H 'User-Agent: opencode' \
        'https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=10')"

    # Official Linux builds are published as llama-bNNNNN-bin-ubuntu-x64.zip.
    ASSET_NAME="$(printf '%s' "$JSON" | grep -oE '"name": *"llama-[^"]*-bin-ubuntu-x64\.zip"' \
        | head -n 1 | sed 's/.*: *"//; s/"$//')"
    if [ -z "$ASSET_NAME" ]; then
        echo "No ubuntu-x64 asset found in recent llama.cpp releases." >&2
        exit 1
    fi
    URL="https://github.com/ggml-org/llama.cpp/releases/latest/download/$ASSET_NAME"

    ZIP="$SCRIPT_DIR/llama.zip"
    echo "  Downloading $ASSET_NAME ..."
    fetch "$URL" "$ZIP"

    echo "  Extracting..."
    if command -v unzip >/dev/null 2>&1; then
        unzip -oq "$ZIP" -d "$BIN_DIR"
    else
        # Fall back to Python's zipfile if unzip is not installed.
        python3 -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$ZIP" "$BIN_DIR"
    fi
    rm -f "$ZIP"
    chmod +x "$BIN_DIR"/llama-* 2>/dev/null || true

    # Flatten the archive if it nested everything in a single subfolder.
    if [ ! -x "$BIN_DIR/llama-server" ]; then
        INNER="$(find "$BIN_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
        if [ -n "$INNER" ]; then
            mv "$INNER"/* "$INNER"/.[!.]* "$BIN_DIR" 2>/dev/null || mv "$INNER"/* "$BIN_DIR"
            rmdir "$INNER" 2>/dev/null || true
        fi
    fi

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
