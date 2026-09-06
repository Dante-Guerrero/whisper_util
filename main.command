#!/usr/bin/env bash
set -uo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VENV_PYTHON="$REPO_ROOT/.venv/bin/python"

finish() {
    local exit_code="$1"
    echo
    if [[ "$exit_code" -eq 0 ]]; then
        echo "Proceso terminado correctamente."
    else
        echo "ERROR: El proceso terminó con código $exit_code."
    fi
    if [[ -t 0 ]]; then
        read -r -p "Pulsa Enter para cerrar..." _ || true
    fi
}

cd "$REPO_ROOT" || exit 1

echo "============================================================"
echo "WHISPER_UTIL - Transcripción de audios en input"
echo "============================================================"

if [[ ! -x "$VENV_PYTHON" ]]; then
    echo "ERROR: No se encontró .venv/bin/python." >&2
    echo "Ejecuta primero: ./scripts/install_whisper.sh" >&2
    finish 1
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_candidate" ]]; then
            eval "$("$brew_candidate" shellenv)"
            break
        fi
    done
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ERROR: No se encontró FFmpeg en PATH." >&2
    echo "Ejecuta primero: ./scripts/install_whisper.sh" >&2
    finish 1
    exit 1
fi

if ! mkdir -p "$REPO_ROOT/input" "$REPO_ROOT/output"; then
    echo "ERROR: No se pudieron crear las carpetas input/ y output/." >&2
    finish 1
    exit 1
fi
"$VENV_PYTHON" "$REPO_ROOT/src/transcribir_whisper.py"
EXIT_CODE=$?
finish "$EXIT_CODE"
exit "$EXIT_CODE"
