@echo off
setlocal
title Setup - llama.cpp + Qwen3-4B-Instruct

cd /d "%~dp0"

echo ============================================
echo   Downloading llama.cpp + Qwen3 4B Instruct model
echo   (this may take several minutes)
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"

set "EXITCODE=%ERRORLEVEL%"

echo.
if "%EXITCODE%"=="0" (
    echo Setup finished. You can now run start-server.bat
) else (
    echo Setup failed with code %EXITCODE%.
)
echo.
pause

endlocal
