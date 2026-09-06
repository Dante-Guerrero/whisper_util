@echo off
setlocal

echo ============================================================
echo Whisper - Transcribir archivos nuevos desde input hacia output
echo ============================================================
echo.

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

cd /d "%REPO_ROOT%"

if not exist ".venv\Scripts\python.exe" (
    echo ERROR: No se encontro .venv\Scripts\python.exe
    echo Primero ejecuta: scripts\instalar_whisper.cmd
    echo.
    pause
    exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo ERROR: No se encontro FFmpeg en el PATH.
    echo Ejecuta primero: scripts\instalar_whisper.cmd
    echo.
    pause
    exit /b 1
)

if not exist "input" mkdir "input"
if not exist "output" mkdir "output"

".venv\Scripts\python.exe" "src\transcribir_whisper.py"
set EXIT_CODE=%ERRORLEVEL%

echo.
echo ============================================================
if %EXIT_CODE% equ 0 (
    echo Proceso terminado correctamente.
) else (
    echo ERROR: El proceso termino con codigo %EXIT_CODE%.
)
echo ============================================================
echo.

pause
exit /b %EXIT_CODE%
