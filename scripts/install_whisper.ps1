# ============================================================
# scripts/install_whisper.ps1
# Instalador de Whisper para Windows / ThinkPad
# Crea el entorno virtual en: root_del_repo/.venv
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host "=== Instalador de Whisper para Windows ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Resolver rutas
# ------------------------------------------------------------

$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptsDir
$VenvDir = Join-Path $RepoRoot ".venv"

Set-Location $RepoRoot

Write-Host "Carpeta scripts:      $ScriptsDir" -ForegroundColor DarkGray
Write-Host "Root del repositorio: $RepoRoot" -ForegroundColor Green
Write-Host "Entorno virtual:      $VenvDir" -ForegroundColor Green

# ------------------------------------------------------------
# 2. Verificar Python
# ------------------------------------------------------------

Write-Host "`nVerificando Python..." -ForegroundColor Cyan

$pythonCmd = $null

if (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = "py"
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} else {
    Write-Host "No se encontro Python. Intentando instalar con winget..." -ForegroundColor Yellow

    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "No se encontro winget. Instala Python manualmente desde https://www.python.org/downloads/windows/"
    }

    winget install -e --id Python.Python.3.12

    Write-Host ""
    Write-Host "Python fue instalado." -ForegroundColor Green
    Write-Host "Cierra y vuelve a abrir PowerShell o CMD, y luego ejecuta nuevamente scripts\instalar_whisper.cmd" -ForegroundColor Yellow
    exit 0
}

Write-Host "Python detectado:" -ForegroundColor Green
& $pythonCmd --version

# ------------------------------------------------------------
# 3. Verificar FFmpeg
# ------------------------------------------------------------

Write-Host "`nVerificando FFmpeg..." -ForegroundColor Cyan

function Test-FFmpeg {
    return [bool](Get-Command ffmpeg -ErrorAction SilentlyContinue)
}

if (!(Test-FFmpeg)) {
    Write-Host "FFmpeg no encontrado en el PATH actual." -ForegroundColor Yellow
    Write-Host "Intentando preparar winget..." -ForegroundColor Yellow

    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "No se encontro winget. Instala FFmpeg manualmente y agregalo al PATH."
    }

    Write-Host "Reparando fuentes de winget..." -ForegroundColor Cyan
    winget source reset --force
    winget source update

    Write-Host "Instalando FFmpeg con winget..." -ForegroundColor Cyan
    winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements

    Write-Host ""
    Write-Host "FFmpeg fue instalado o actualizado." -ForegroundColor Green

    # Intentar refrescar PATH desde variables de entorno del sistema y usuario
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    if (!(Test-FFmpeg)) {
        Write-Host ""
        Write-Host "FFmpeg se instalo, pero aun no esta disponible en esta terminal." -ForegroundColor Yellow
        Write-Host "Cierra VS Code y PowerShell completamente, vuelve a abrirlos y ejecuta:" -ForegroundColor Yellow
        Write-Host "ffmpeg -version" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Luego corre:" -ForegroundColor Yellow
        Write-Host ".\main.cmd" -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "FFmpeg detectado:" -ForegroundColor Green
ffmpeg -version | Select-Object -First 1

# ------------------------------------------------------------
# 4. Crear entorno virtual
# ------------------------------------------------------------

Write-Host "`nCreando entorno virtual..." -ForegroundColor Cyan

if (!(Test-Path $VenvDir)) {
    & $pythonCmd -m venv $VenvDir
    Write-Host "Entorno virtual creado." -ForegroundColor Green
} else {
    Write-Host "El entorno virtual ya existe. Se reutilizara." -ForegroundColor Yellow
}

# ------------------------------------------------------------
# 5. Activar entorno virtual
# ------------------------------------------------------------

$ActivateScript = Join-Path $VenvDir "Scripts\Activate.ps1"

if (!(Test-Path $ActivateScript)) {
    throw "No se encontro el script de activacion del entorno virtual: $ActivateScript"
}

. $ActivateScript

Write-Host "Entorno virtual activado." -ForegroundColor Green

# ------------------------------------------------------------
# 6. Actualizar pip
# ------------------------------------------------------------

Write-Host "`nActualizando pip, setuptools y wheel..." -ForegroundColor Cyan

python -m pip install --upgrade pip setuptools wheel

# ------------------------------------------------------------
# 7. Instalar Whisper
# ------------------------------------------------------------

Write-Host "`nInstalando OpenAI Whisper..." -ForegroundColor Cyan

pip install --upgrade openai-whisper

# ------------------------------------------------------------
# 8. Verificar instalación
# ------------------------------------------------------------

Write-Host "`nVerificando instalacion de Whisper..." -ForegroundColor Cyan

python -c "import whisper; print('Whisper instalado correctamente')"

Write-Host ""
Write-Host "Instalacion finalizada correctamente." -ForegroundColor Green

Write-Host ""
Write-Host "Para transcribir archivos desde input hacia output:" -ForegroundColor Cyan
Write-Host "scripts\transcribir_input.cmd"