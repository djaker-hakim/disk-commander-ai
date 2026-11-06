# Disk Commander AI

Portable local-AI setup: OpenCode driven by a local llama.cpp server (Qwen3-4B-Instruct-2507, 8K context).
Works on **Windows** (`*.bat` / `*.ps1`) and **Linux** (`*.sh`) — each platform is a self-contained folder.

## Layout

| Folder | What it is |
|---|---|
| `opencode/windows\` | OpenCode for Windows — `opencode.exe` + `start-opencode.bat` |
| `opencode/linux/` | OpenCode for Linux — `opencode` + `start-opencode.sh` |
| `opencode/opencode.example.json` | Shared config template (both platforms use it) |
| `server/windows\` | llama.cpp for Windows — `bin\`, `start-server.bat`, `launch-server.ps1`, `setup.bat`, `setup.ps1`, `download-model.ps1` |
| `server/linux/` | llama.cpp for Linux — `bin/`, `start-server.sh`, `setup.sh`, `download-model.sh` |
| `server/models\` | Shared GGUF model storage (used by both platforms) |
| `workspace\` | Working directory — the live `opencode.json` lives here; OpenCode runs from this folder |

Plus at this level:
- **`diskCommander-windows.bat`** — one-click launcher for Windows
- **`diskCommander-linux.sh`** — one-click launcher for Linux

Binaries (`opencode.exe`, `opencode`, `bin\`) are gitignored — see "Fresh setup".

## How to start

### Windows

**One click:** double-click **`diskCommander-windows.bat`**. It:

1. Reuses the server if it's already running, otherwise starts it in its own
   minimized window and waits until the model is loaded
2. Launches OpenCode in the workspace
3. When you exit OpenCode, asks whether to stop the server too

Running it again while the server is up simply reuses it — no port conflict.

**Manual alternative:**

1. Double-click **`server\windows\start-server.bat`** and wait for `listening on http://127.0.0.1:8090`
2. Double-click **`opencode\windows\start-opencode.bat`**

### Linux

**One click:** run **`./diskCommander-linux.sh`** from a terminal (or a desktop
launcher pointing to it). It:

1. Reuses the server if it's already running, otherwise starts it in the
   background (`server/server.log`, PID in `server/server.pid`) and waits until
   the model is loaded
2. Launches OpenCode in the workspace
3. When you exit OpenCode, asks whether to stop the server too

**Manual alternative:**

1. Run **`server/linux/start-server.sh`** and wait for `listening on 127.0.0.1:8090`
2. In another terminal, run **`opencode/linux/start-opencode.sh`**
   (or add `--standalone`)

The launcher automatically runs OpenCode inside `workspace/`, so the `opencode.json`
there is loaded. If it's missing (fresh USB), the launcher copies it from
`opencode/opencode.example.json` for you.

## Fresh setup (new machine / new USB)

**Windows:** run **`server\windows\setup.bat`** — downloads llama.cpp (AVX2 build) + the model (~2.5 GB)

**Linux:** run **`server/linux/setup.sh`** — downloads llama.cpp (ubuntu-x64 build) + the model (~2.5 GB):

```bash
server/linux/setup.sh               # llama.cpp Linux binaries + model
./diskCommander-linux.sh            # or: server/linux/start-server.sh + opencode/linux/start-opencode.sh
```

The OpenCode binaries (both platforms) are **not** bundled — they exceed
GitHub's 100 MB limit. Drop them into place yourself:

- Windows: `opencode/windows/opencode.exe`
- Linux: `opencode/linux/opencode` (then `chmod +x opencode/linux/opencode`)

Or install via PATH and the launchers find it automatically.

### Model download only

```bash
server/linux/download-model.sh                 # default model
server/linux/download-model.sh Q8_0            # different quant of the same repo
server/linux/download-model.sh <repo-id> <file.gguf>   # any other model
```

## Notes

- All scripts resolve paths relative to their own location (`%~dp0` / `dirname "$0"`),
  so the whole `AI Models usb` folder can be moved or copied anywhere as a unit.
- Shell scripts are stored with LF line endings (`.gitattributes` enforces this),
  so they run correctly on Linux even if the repo was checked out on Windows.
- The server uses port **8090** (not 8080 — Docker/WSL often take that).
- Change the port in `server\windows\launch-server.ps1`, in `server/linux/start-server.sh`,
  and in the `baseURL` of `workspace\opencode.json` if 8090 is taken.
