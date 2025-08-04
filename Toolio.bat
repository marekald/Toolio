@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo solicitando permisos de administrador...
    powershell -command "start-process '%~f0' -verb runas"
    exit /b
)

powershell -ExecutionPolicy Bypass -File "%~dp0main.ps1"
pause
