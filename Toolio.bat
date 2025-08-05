@echo off
REM net session >nul 2>&1
REM if %errorlevel% neq 0 (
    REM echo solicitando permisos de administrador...
    REM powershell -command "start-process '%~f0' -verb runas"
    REM exit /b
REM )

powershell -ExecutionPolicy Bypass -File "%~dp0ToolioUI.ps1"
