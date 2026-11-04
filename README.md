# Disk Commander AI

Portable local-AI setup: OpenCode driven by a local llama.cpp server (Qwen3-4B-Instruct-2507, 8K context).

## Layout

| Folder | What it is |
|---|---|
| `opencode\` | OpenCode app — `opencode.exe`, the launcher (`start-opencode.bat`), and the config template (`opencode.example.json`) |
| `server\` | llama.cpp server — `bin\` (llama-server.exe), `models\` (GGUF), `start-server.bat`, setup/download scripts |
| `workspace\` | Working directory — the live `opencode.json` lives here; OpenCode runs from this folder |

Plus **`diskCommander.bat`** at this level — the one-click launcher for both (see "How to start").

## How to start

**One click:** double-click **`diskCommander.bat`** (in this folder). It:

1. Reuses the server if it's already running, otherwise starts it in its own
   minimized window and waits until the model is loaded
2. Launches OpenCode in the workspace
3. When you exit OpenCode, asks whether to stop the server too

Running it again while the server is up simply reuses it — no port conflict.

**Manual alternative:**

1. Double-click **`server\start-server.bat`** and wait for `listening on http://127.0.0.1:8090`
2. Double-click **`opencode\start-opencode.bat`**

The launcher automatically runs OpenCode inside `workspace\`, so the `opencode.json`
there is loaded. If it's missing (fresh USB), the launcher copies it from
`opencode\opencode.example.json` for you.

## Fresh setup (new machine / new USB)

1. Run **`server\setup.bat`** — downloads llama.cpp (AVX2 build) + the model (~2.5 GB)
2. Then follow "How to start" above.

## Notes

- All scripts use paths relative to their own location (`%~dp0` / `$PSScriptRoot`),
  so the whole `AI Models usb` folder can be moved or copied anywhere as a unit.
- The server uses port **8090** (not 8080 — Docker/WSL often take that).
- Change the port in `server\launch-server.ps1` and in the `baseURL` of
  `workspace\opencode.json` if 8090 is taken.
