@echo off
setlocal
title diskCommander - AI Models usb

set "ROOT=%~dp0"

echo ==============================================
echo   diskCommander
echo   One click: llama.cpp server + OpenCode
echo ==============================================
echo.

rem ---- 1. Reuse the server if it is already running -----------------------
curl.exe -s --max-time 3 http://127.0.0.1:8090/health 2>nul | find /i "ok" >nul
if not errorlevel 1 (
    echo [1/2] Server already running on port 8090 - reusing it.
    goto :server-ready
)

rem ---- 2. Start the server in its own (minimized) window ------------------
echo [1/2] Starting llama.cpp server in a separate window...
start "llama.cpp server (diskCommander)" /min cmd /c ""%ROOT%server\windows\start-server.bat""

echo       Waiting for the model to load...
set /a tries=0

:wait-loop
timeout /t 2 /nobreak >nul
curl.exe -s --max-time 3 http://127.0.0.1:8090/health 2>nul | find /i "ok" >nul
if not errorlevel 1 goto :server-ready
set /a tries+=1
if %tries% GEQ 90 (
    echo.
    echo WARNING: server not ready after 3 minutes - starting OpenCode anyway.
    echo          Check the llama.cpp server window for errors.
    goto :server-ready
)
goto :wait-loop

:server-ready
echo [2/2] Starting OpenCode in the workspace...
echo.
call "%ROOT%opencode\windows\start-opencode.bat"

echo.
echo OpenCode closed.
choice /c YN /n /m "Stop the llama.cpp server too? [Y/n] "
if errorlevel 2 goto :keep-server

echo Stopping server...
taskkill /im llama-server.exe /f >nul 2>&1
echo Done.
goto :end

:keep-server
echo Server still running in its separate window - close that window to stop
echo it, or run diskCommander again to reuse it.

:end
endlocal
