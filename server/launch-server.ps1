<#
.SYNOPSIS
    Starts the local llama.cpp server for Qwen3-4B-Instruct-2507 with an 8K context.

.NOTES
    Serves an OpenAI-compatible API at http://127.0.0.1:8090/v1
    (opencode.json in the ..\workspace folder points here).

    Port 8080 is intentionally NOT used: Docker Desktop and WSL often occupy it,
    which makes requests hit Docker instead of llama.cpp.
#>

$Root        = $PSScriptRoot
$ModelPath   = Join-Path $Root "models\Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
$LlamaServer = Join-Path $Root "bin\llama-server.exe"
$Port        = 8090
$CtxSize     = 8192
$Alias       = "qwen3-4b-instruct"

if (-not (Test-Path $ModelPath))   { Write-Host "Model missing. Run .\setup.ps1 first." -ForegroundColor Red; exit 1 }
if (-not (Test-Path $LlamaServer)) { Write-Host "llama-server missing. Run .\setup.ps1 first." -ForegroundColor Red; exit 1 }

# Refuse to start if the port is already taken by something else.
$busy = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($busy) {
    $owner = ($busy | ForEach-Object { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } | Select-Object -Unique) -join ", "
    Write-Host "Port $Port is already in use by: $owner" -ForegroundColor Red
    Write-Host "Stop that process, or change `$Port in this script (and baseURL in opencode.json)." -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting llama.cpp server" -ForegroundColor Cyan
Write-Host "  model : $ModelPath"
Write-Host "  alias : $Alias"
Write-Host "  ctx   : $CtxSize tokens"
Write-Host "  url   : http://127.0.0.1:$Port/v1"
Write-Host "  stop  : Ctrl+C"
Write-Host ""

& $LlamaServer `
    --model $ModelPath `
    --alias $Alias `
    --host 127.0.0.1 `
    --port $Port `
    --ctx-size $CtxSize `
    --parallel 1 `
    --jinja `
    --cache-type-k q8_0 `
    --temp 0.2 `
    --no-warmup
