<#
.SYNOPSIS
    Downloads llama.cpp (Windows AVX2 build) and the Qwen3-4B-Instruct-2507
    GGUF model into this folder (bin\ and models\).
#>

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Root      = $PSScriptRoot
$ModelDir  = Join-Path $Root "models"
$BinDir    = Join-Path $Root "bin"
$ModelName = "Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
$ModelPath = Join-Path $ModelDir $ModelName
$ModelUrl  = "https://huggingface.co/bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"

function Get-File {
    param([string]$Url, [string]$OutFile)

    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        & curl.exe -L --fail --retry 3 -C - -o $OutFile $Url
        if ($LASTEXITCODE -ne 0) { throw "curl failed with exit code $LASTEXITCODE for $Url" }
    } else {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
    }
}

Write-Host "=== AI Models USB setup ===" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $ModelDir | Out-Null
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# --- 1. llama.cpp ---------------------------------------------------------
if (Test-Path (Join-Path $BinDir "llama-server.exe")) {
    Write-Host "[1/2] llama.cpp already present." -ForegroundColor Green
} else {
    Write-Host "[1/2] Resolving latest llama.cpp Windows release..." -ForegroundColor Yellow
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=10" -Headers @{ "User-Agent" = "opencode" }

    # Newer releases publish llama-bNNNNN-bin-win-{cpu,avx2,vulkan,cuda}-x64.zip.
    # Prefer an AVX2/CPU build (no external runtime deps), newest release first.
    $asset = $null
    foreach ($rel in $releases) {
        $asset = $rel.assets |
            Where-Object { $_.name -match '^llama-.*-bin-win-(avx2|cpu)-x64\.zip$' } |
            Sort-Object { if ($_.name -match 'avx2') { 0 } else { 1 } } |
            Select-Object -First 1
        if ($asset) { break }
    }

    if (-not $asset) {
        Write-Host "Recent releases checked:" -ForegroundColor DarkGray
        $releases | ForEach-Object { Write-Host "  $($_.tag_name)" -ForegroundColor DarkGray }
        throw "No win x64 zip asset found in recent llama.cpp releases."
    }

    $zip = Join-Path $Root "llama.zip"
    Write-Host "  Downloading $($asset.name) ..." -ForegroundColor Yellow
    Get-File -Url $asset.browser_download_url -OutFile $zip

    Write-Host "  Extracting..." -ForegroundColor Yellow
    Expand-Archive -Path $zip -DestinationPath $BinDir -Force
    Remove-Item $zip -Force

    # If the archive nested everything in a single subfolder, flatten it.
    if (-not (Test-Path (Join-Path $BinDir "llama-server.exe"))) {
        $inner = Get-ChildItem $BinDir -Directory | Select-Object -First 1
        if ($inner) {
            Get-ChildItem $inner.FullName -Force | Move-Item -Destination $BinDir -Force
            Remove-Item $inner.FullName -Recurse -Force
        }
    }

    if (Test-Path (Join-Path $BinDir "llama-server.exe")) {
        Write-Host "[1/2] llama.cpp ready." -ForegroundColor Green
    } else {
        throw "llama-server.exe not found after extraction."
    }
}

# --- 2. Model -------------------------------------------------------------
if (Test-Path $ModelPath) {
    Write-Host "[2/2] Model already present." -ForegroundColor Green
} else {
    Write-Host "[2/2] Downloading $ModelName (~2.5 GB) ..." -ForegroundColor Yellow
    Get-File -Url $ModelUrl -OutFile $ModelPath
    Write-Host "[2/2] Model ready." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "Model : $ModelPath"
Write-Host "Bin   : $BinDir"
Write-Host "Start the server with: .\launch-server.ps1"
