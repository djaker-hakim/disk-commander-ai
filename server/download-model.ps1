# Downloads Qwen3-4B-Instruct-2507 Q4_K_M into models\ with resume support.
$ErrorActionPreference = "Stop"

$Root      = $PSScriptRoot
$ModelPath = Join-Path $Root "models\Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"
$ModelUrl  = "https://huggingface.co/bartowski/Qwen_Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen_Qwen3-4B-Instruct-2507-Q4_K_M.gguf"

& curl.exe -L --fail --retry 3 -C - --silent --show-error -o $ModelPath $ModelUrl
if ($LASTEXITCODE -ne 0) { Write-Host "DOWNLOAD_FAILED exit=$LASTEXITCODE"; exit 1 }

if (Test-Path $ModelPath) {
    $size = (Get-Item $ModelPath).Length
    Write-Host ("DOWNLOAD_OK size=" + $size)
} else {
    Write-Host "DOWNLOAD_FAILED missing-file"
    exit 1
}
