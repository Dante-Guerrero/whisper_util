@echo off
setlocal

echo ============================================================
echo Instalador de Whisper para Windows
echo ============================================================
echo.

set SCRIPT_DIR=%~dp0

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install_whisper.ps1"
set EXIT_CODE=%ERRORLEVEL%

echo.
echo ============================================================
echo Proceso terminado.
echo Si hubo errores, revisa los mensajes anteriores.
echo ============================================================
echo.

pause
exit /b %EXIT_CODE%
