@echo off
setlocal
title OpenCode - AI Models usb

rem ==== Locate opencode.exe ==============================================
rem 1. Explicit override: set OPENCODE_EXE=C:\path\to\opencode.exe
if exist "%OPENCODE_EXE%" goto :found

rem 2. Portable copy in this folder (preferred for USB use)
set "OPENCODE_EXE=%~dp0opencode.exe"
if exist "%OPENCODE_EXE%" goto :found

rem 3. On PATH
set "OPENCODE_EXE="
for %%I in (opencode.exe) do if not "%%~$PATH:I"=="" set "OPENCODE_EXE=%%~$PATH:I"
if defined OPENCODE_EXE goto :found

rem 4. Common install locations
if exist "%USERPROFILE%\.opencode\bin\opencode.exe" set "OPENCODE_EXE=%USERPROFILE%\.opencode\bin\opencode.exe"
if defined OPENCODE_EXE goto :found

if exist "%LOCALAPPDATA%\Programs\opencode\opencode.exe" set "OPENCODE_EXE=%LOCALAPPDATA%\Programs\opencode\opencode.exe"
if defined OPENCODE_EXE goto :found

echo opencode.exe was not found.
echo.
echo Install it, add it to PATH, or point this script at it:
echo   set OPENCODE_EXE=C:\path\to\opencode.exe
echo.
pause
exit /b 1

:found
rem ==== Run from the workspace folder ====================================
rem OpenCode loads opencode.json from the working directory, and sessions
rem get their files from there too.
if not exist "%~dp0..\..\workspace" mkdir "%~dp0..\..\workspace"
cd /d "%~dp0..\..\workspace"

rem First run on a fresh USB: seed the live config from the template.
if not exist "opencode.json" (
    copy /y "%~dp0..\opencode.example.json" "opencode.json" >nul
    echo Created opencode.json from opencode.example.json
)

echo Working directory: %CD%
echo Using: %OPENCODE_EXE%
echo.
echo Agents: powershell (default - shell only)
echo         files      (read/write only, no shell)
echo.
echo   start-opencode.bat                   - PowerShell agent
echo   start-opencode.bat --agent files     - file agent
echo.

"%OPENCODE_EXE%" %*
set "EXITCODE=%ERRORLEVEL%"

endlocal & exit /b %EXITCODE%
