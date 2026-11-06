@echo off
setlocal
title Local Model Server - Qwen3-4B-Instruct-2507 (llama.cpp)

cd /d "%~dp0"

echo ============================================
echo   Starting local llama.cpp server
echo   Model:    Qwen3 4B Instruct 2507 (Q4_K_M)
echo   Context:  8192 tokens
echo   Endpoint: http://127.0.0.1:8090/v1
echo   Stop with: Ctrl+C
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch-server.ps1"

set "EXITCODE=%ERRORLEVEL%"

rem Ctrl+C on Windows reports as 0xC000013A; that is a normal stop, not a failure.
if "%EXITCODE%"=="0" goto :done
if "%EXITCODE%"=="-1073741510" goto :done
if "%EXITCODE%"=="3221225786" goto :done

echo.
echo The server exited with code %EXITCODE%.
echo If the model or llama-server is missing, run setup.bat first.
echo.
pause

:done
endlocal
