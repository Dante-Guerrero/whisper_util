$ErrorActionPreference = "Stop"

try {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "WHISPER_UTIL - Instalacion para Windows" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    $ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoRoot = Split-Path -Parent $ScriptsDir
    $VenvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
    $Requirements = Join-Path $RepoRoot "requirements.txt"
    Set-Location $RepoRoot

    function Invoke-SystemPython {
        param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
        if ($script:UsePyLauncher) {
            & py $script:PyVersion @Arguments
        } else {
            & $script:SystemPython @Arguments
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Python termino con codigo $LASTEXITCODE."
        }
    }

    $script:UsePyLauncher = $false
    $script:PyVersion = $null
    $script:SystemPython = $null
    if (Get-Command py -ErrorAction SilentlyContinue) {
        foreach ($version in @("-3.13", "-3.12", "-3.11", "-3.10", "-3.9")) {
            & py $version -c "import sys" *> $null
            if ($LASTEXITCODE -eq 0) {
                $script:UsePyLauncher = $true
                $script:PyVersion = $version
                break
            }
        }
    }
    if (!$script:UsePyLauncher -and (Get-Command python -ErrorAction SilentlyContinue)) {
        $candidatePython = (Get-Command python).Source
        & $candidatePython -c "import sys; raise SystemExit(0 if (3, 9) <= sys.version_info[:2] <= (3, 13) else 1)" *> $null
        if ($LASTEXITCODE -eq 0) { $script:SystemPython = $candidatePython }
    }
    if (!$script:UsePyLauncher -and !$script:SystemPython) {
        Write-Host "No se encontro Python 3.9-3.13. Instalando Python 3.12 con winget..." -ForegroundColor Yellow
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "No se encontro winget. Instala Python 3 desde https://www.python.org/downloads/windows/ y vuelve a ejecutar este instalador."
        }
        winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "winget no pudo instalar Python." }
        Write-Host "Python fue instalado. Cierra y vuelve a abrir la terminal, y ejecuta otra vez scripts\instalar_whisper.cmd." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "`nPython detectado:" -ForegroundColor Green
    Invoke-SystemPython @("--version")

    function Test-FFmpeg { return [bool](Get-Command ffmpeg -ErrorAction SilentlyContinue) }
    if (!(Test-FFmpeg)) {
        Write-Host "`nFFmpeg no encontrado. Instalando con winget..." -ForegroundColor Yellow
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            throw "No se encontro winget. Instala FFmpeg manualmente y agregalo al PATH."
        }
        winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "winget no pudo instalar FFmpeg." }
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"
    }

    if (!(Test-FFmpeg)) {
        throw "FFmpeg se instalo, pero aun no aparece en PATH. Reinicia la terminal y ejecuta nuevamente el instalador."
    }
    Write-Host "`nFFmpeg detectado:" -ForegroundColor Green
    ffmpeg -version | Select-Object -First 1

    if (!(Test-Path $VenvPython)) {
        Write-Host "`nCreando entorno virtual..." -ForegroundColor Cyan
        Invoke-SystemPython @("-m", "venv", (Join-Path $RepoRoot ".venv"))
    } else {
        Write-Host "`nEl entorno virtual ya existe; se reutilizara." -ForegroundColor Yellow
    }

    if (!(Test-Path $VenvPython)) { throw "No se pudo crear $VenvPython" }

    Write-Host "Actualizando pip, setuptools y wheel..." -ForegroundColor Cyan
    & $VenvPython -m pip install --upgrade pip setuptools wheel
    if ($LASTEXITCODE -ne 0) { throw "No se pudieron actualizar las herramientas de instalacion." }

    Write-Host "Instalando dependencias Python..." -ForegroundColor Cyan
    & $VenvPython -m pip install -r $Requirements
    if ($LASTEXITCODE -ne 0) { throw "No se pudieron instalar las dependencias Python." }

    & $VenvPython -c "import whisper; print('Whisper instalado correctamente')"
    if ($LASTEXITCODE -ne 0) { throw "La verificacion de Whisper fallo." }
    if (!(Test-FFmpeg)) { throw "La verificacion final de FFmpeg fallo." }

    Write-Host "`nInstalacion finalizada correctamente." -ForegroundColor Green
    Write-Host "Ejecuta main.cmd para transcribir los archivos de input\." -ForegroundColor Cyan
    exit 0
} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
