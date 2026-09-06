@echo off
setlocal

echo ============================================================
echo WHISPER_UTIL - Transcripcion de audios en input
echo ============================================================
echo.

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo ERROR: No se encontro .venv\Scripts\python.exe
    echo.
    echo Primero ejecuta:
    echo scripts\instalar_whisper.cmd
    echo.
    pause
    exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo ERROR: No se encontro FFmpeg en el PATH.
    echo.
    echo Ejecuta:
    echo scripts\instalar_whisper.cmd
    echo.
    echo Si el instalador ya corrio, cierra VS Code completamente,
    echo vuelve a abrirlo y prueba:
    echo ffmpeg -version
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
