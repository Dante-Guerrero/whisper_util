#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
VENV_PYTHON="$REPO_ROOT/.venv/bin/python"

echo "============================================================"
echo "WHISPER_UTIL - Instalación para macOS"
echo "============================================================"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "ERROR: Este instalador está diseñado para macOS." >&2
    exit 1
fi

find_brew() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
    elif [[ -x /opt/homebrew/bin/brew ]]; then
        echo /opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
        echo /usr/local/bin/brew
    else
        return 1
    fi
}

if ! BREW_BIN="$(find_brew)"; then
    echo "ERROR: Homebrew no está instalado." >&2
    echo "Instálalo siguiendo https://brew.sh/ y vuelve a ejecutar este script." >&2
    exit 1
fi
eval "$("$BREW_BIN" shellenv)"

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "FFmpeg no encontrado. Instalando con Homebrew..."
    brew install ffmpeg
fi
echo "FFmpeg detectado: $(ffmpeg -version | head -n 1)"

PYTHON_BIN=""
for candidate in python3.13 python3.12 python3.11 python3.10 python3.9 python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
        candidate_path="$(command -v "$candidate")"
        if "$candidate_path" -c 'import sys; raise SystemExit(not ((3, 9) <= sys.version_info[:2] <= (3, 13)))'; then
            PYTHON_BIN="$candidate_path"
            break
        fi
    fi
done

if [[ -z "$PYTHON_BIN" ]]; then
    echo "No se encontró Python 3.9–3.13. Instalando Python 3.13 con Homebrew..."
    brew install python@3.13
    PYTHON_BIN="$(brew --prefix python@3.13)/bin/python3.13"
fi
echo "Python detectado: $($PYTHON_BIN --version 2>&1)"

cd "$REPO_ROOT"
if [[ ! -x "$VENV_PYTHON" ]]; then
    echo "Creando entorno virtual..."
    "$PYTHON_BIN" -m venv "$REPO_ROOT/.venv"
else
    echo "El entorno virtual ya existe; se reutilizará."
fi

echo "Actualizando pip, setuptools y wheel..."
"$VENV_PYTHON" -m pip install --upgrade pip setuptools wheel
echo "Instalando dependencias Python..."
"$VENV_PYTHON" -m pip install -r "$REPO_ROOT/requirements.txt"

"$VENV_PYTHON" -c "import whisper; print('Whisper instalado correctamente')"
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ERROR: FFmpeg no está disponible en PATH después de la instalación." >&2
    exit 1
fi

echo "Instalación finalizada correctamente."
echo "Ejecuta ./main.command para transcribir los archivos de input/."
