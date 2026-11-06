# Disk Commander AI

Portable local-AI setup: OpenCode driven by a local llama.cpp server (Qwen3-4B-Instruct-2507, 8K context).
Works on **Windows** (`*.bat` / `*.ps1`) and **Linux** (`*.sh`).

## Layout

| Folder | What it is |
|---|---|
| `opencode\` | OpenCode app — `opencode.exe`, the launcher (`start-opencode.bat`), and the config template (`opencode.example.json`) |
| `server\` | llama.cpp server — `bin\` (llama-server.exe), `models\` (GGUF), `start-server.bat`, setup/download scripts |
| `workspace\` | Working directory — the live `opencode.json` lives here; OpenCode runs from this folder |

Plus **`diskCommander.bat`** (Windows) / **`diskCommander.sh`** (Linux) at this
level — the one-click launchers for both (see "How to start").

## How to start

### Windows

**One click:** double-click **`diskCommander.bat`** (in this folder). It:

1. Reuses the server if it's already running, otherwise starts it in its own
   minimized window and waits until the model is loaded
2. Launches OpenCode in the workspace
3. When you exit OpenCode, asks whether to stop the server too

Running it again while the server is up simply reuses it — no port conflict.

**Manual alternative:**

1. Double-click **`server\start-server.bat`** and wait for `listening on http://127.0.0.1:8090`
2. Double-click **`opencode\start-opencode.bat`**

### Linux

**One click:** run **`./diskCommander.sh`** from a terminal (or a desktop
launcher pointing to it). It:

1. Reuses the server if it's already running, otherwise starts it in the
   background (`server/server.log`, PID in `server/server.pid`) and waits until
   the model is loaded
2. Launches OpenCode in the workspace
3. When you exit OpenCode, asks whether to stop the server too

**Manual alternative:**

1. Run **`server/start-server.sh`** and wait for `listening on 127.0.0.1:8090`
2. In another terminal, run **`opencode/start-opencode.sh`**
   (or `--standalone` for the standalone TUI)

The launcher automatically runs OpenCode inside `workspace/`, so the `opencode.json`
there is loaded. If it's missing (fresh USB), the launcher copies it from
`opencode/opencode.example.json` for you.

## Fresh setup (new machine / new USB)

**Windows:** run **`server\setup.bat`** — downloads llama.cpp (AVX2 build) + the model (~2.5 GB)
**Linux:** run **`server/setup.sh`** — downloads llama.cpp (ubuntu-x64 build) + the model (~2.5 GB)

```bash
server/setup.sh                     # llama.cpp Linux binaries + model
./diskCommander.sh                  # or: server/start-server.sh + opencode/start-opencode.sh
```

The OpenCode Linux binary is **not** bundled (GitHub 100 MB limit, same as the
Windows one). Drop it into `opencode/` as `opencode`, install it via PATH, or
point the launcher at it: `OPENCODE_EXE=/path/to/opencode ./diskCommander.sh`.

### Model download only

Download just the model (default: Qwen3-4B-Instruct-2507 Q4_K_M) with:

```bash
server/download-model.sh                 # default model
server/download-model.sh Q8_0            # different quant of the same repo
server/download-model.sh <repo-id> <file.gguf>   # any other model
```

## Notes

- All scripts use paths relative to their own location (`%~dp0` / `dirname "$0"`),
  so the whole `AI Models usb` folder can be moved or copied anywhere as a unit.
- Shell scripts are stored with LF line endings (`.gitattributes` enforces this),
  so they run correctly on Linux even if the repo was checked out on Windows.
- The server uses port **8090** (not 8080 — Docker/WSL often take that).
- Change the port in `server\launch-server.ps1` and in the `baseURL` of
  `workspace\opencode.json` if 8090 is taken.
