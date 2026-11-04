#!/usr/bin/env bash
# Downloads a GGUF model into models/ with resume support (Linux/macOS).
# Windows equivalent: download-model.ps1
#
# Default model: Qwen3-4B-Instruct-2507 Q4_K_M (the model this project uses).
#
# Usage:
#   ./download-model.sh                                # default model
#   ./download-model.sh Q8_0                           # different quant, same repo
#   ./download-model.sh Model-name-Q4_K_M.gguf         # different file, same repo
#   ./download-model.sh <repo-id> <file.gguf>          # fully custom
#   e.g. ./download-model.sh bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf

set -euo pipefail

REPO="bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF"
FILE="Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"

case $# in
    0) ;;
    1)
        case "$1" in
            *.gguf) FILE="$1" ;;
            Q*)     FILE="Qwen_Qwen3-4B-Instruct-2507-$1.gguf" ;;
            *)      FILE="$1" ;;
        esac
        ;;
    2) REPO="$1"; FILE="$2" ;;
    *) echo "Usage: $0 [quant | file.gguf | <repo-id> <file.gguf>]" >&2; exit 1 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODELS_DIR="$SCRIPT_DIR/models"
OUT="$MODELS_DIR/$FILE"
URL="https://huggingface.co/$REPO/resolve/main/$FILE"

mkdir -p "$MODELS_DIR"

echo "Repo : $REPO"
echo "File : $FILE"
echo "Into : $MODELS_DIR"
echo "URL  : $URL"
echo

if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 -C - --output "$OUT" "$URL"
elif command -v wget >/dev/null 2>&1; then
    wget -c -O "$OUT" "$URL"
else
    echo "DOWNLOAD_FAILED: need curl or wget" >&2
    exit 1
fi

if [ -s "$OUT" ]; then
    echo "DOWNLOAD_OK: $OUT ($(du -h "$OUT" | cut -f1))"
else
    echo "DOWNLOAD_FAILED: file missing or empty" >&2
    exit 1
fi
