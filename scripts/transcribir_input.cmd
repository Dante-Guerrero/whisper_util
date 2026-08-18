@echo off
setlocal

echo ============================================================
echo Whisper - Transcribir archivos nuevos desde input hacia output
echo ============================================================
echo.

set SCRIPT_DIR=%~dp0
set REPO_ROOT=%SCRIPT_DIR%..

cd /d "%REPO_ROOT%"

if not exist ".venv\Scripts\python.exe" (
    echo No se encontro .venv\Scripts\python.exe
    echo Primero ejecuta: scripts\instalar_whisper.cmd
    echo.
    pause
    exit /b 1
)

if not exist "input" (
    echo No existe la carpeta input.
    echo Creando carpeta input...
    mkdir input
)

if not exist "output" (
    echo No existe la carpeta output.
    echo Creando carpeta output...
    mkdir output
)

".venv\Scripts\python.exe" "src\transcribir_whisper.py" --input input --output output --modelo small --idioma Spanish

echo.
echo ============================================================
echo Proceso terminado.
echo ============================================================
echo.

pause