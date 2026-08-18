@echo off
setlocal

REM ============================================================
REM Configuracion facil
REM Modelos disponibles: tiny, base, small, medium, large
REM ============================================================

set MODELO=large
set IDIOMA=Spanish
set INPUT_DIR=input
set OUTPUT_DIR=output

REM ============================================================
REM WHISPER_UTIL
REM ============================================================

echo ============================================================
echo WHISPER_UTIL - Transcripcion de audios en input
echo ============================================================
echo.
echo Modelo: %MODELO%
echo Idioma: %IDIOMA%
echo Input:  %INPUT_DIR%
echo Output: %OUTPUT_DIR%
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

if not exist "%INPUT_DIR%" (
    echo No existe la carpeta %INPUT_DIR%. Creandola...
    mkdir "%INPUT_DIR%"
)

if not exist "%OUTPUT_DIR%" (
    echo No existe la carpeta %OUTPUT_DIR%. Creandola...
    mkdir "%OUTPUT_DIR%"
)

".venv\Scripts\python.exe" src\transcribir_whisper.py --input "%INPUT_DIR%" --output "%OUTPUT_DIR%" --modelo "%MODELO%" --idioma "%IDIOMA%"

echo.
echo ============================================================
echo Proceso terminado.
echo ============================================================
echo.

pause