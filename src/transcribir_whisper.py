# ============================================================
# src/transcribir_whisper.py
# Transcribe archivos nuevos desde input/ hacia output/
#
# Regla:
# - Si existe output/NOMBRE.txt, se considera ya transcrito.
# - Si no existe, se transcribe input/NOMBRE.ext.
# - Si borras el TXT, se vuelve a transcribir.
# ============================================================

from pathlib import Path
import argparse
import shutil
import sys
import time


EXTENSIONES_AUDIO_VIDEO = {
    ".mp3",
    ".opus",
    ".wav",
    ".m4a",
    ".aac",
    ".ogg",
    ".flac",
    ".wma",
    ".mp4",
    ".mov",
    ".mkv",
    ".avi",
    ".webm",
}

MODELO_PREDETERMINADO = "large"


def obtener_repo_root() -> Path:
    """
    Este archivo vive en:
        WHISPER_UTIL/src/transcribir_whisper.py

    Por tanto:
        Path(__file__).parent.parent = WHISPER_UTIL
    """
    return Path(__file__).resolve().parent.parent


def encontrar_archivos_pendientes(input_dir: Path, output_dir: Path) -> list[Path]:
    pendientes: list[Path] = []

    for archivo in sorted(input_dir.iterdir()):
        if not archivo.is_file():
            continue

        if archivo.suffix.lower() not in EXTENSIONES_AUDIO_VIDEO:
            continue

        txt_salida = output_dir / f"{archivo.stem}.txt"

        if not txt_salida.exists():
            pendientes.append(archivo)

    return pendientes


def transcribir_archivo(
    archivo: Path,
    output_dir: Path,
    model,
    idioma: str,
) -> Path:
    txt_salida = output_dir / f"{archivo.stem}.txt"
    txt_temporal = output_dir / f"{archivo.stem}.tmp"

    print()
    print("------------------------------------------------------------")
    print(f"Archivo: {archivo.name}")
    print(f"Salida:  {txt_salida}")
    print("------------------------------------------------------------")

    inicio = time.time()

    result = model.transcribe(
        str(archivo),
        language=idioma,
        verbose=True,
    )

    texto = result.get("text", "").strip()

    txt_temporal.write_text(texto, encoding="utf-8")
    txt_temporal.replace(txt_salida)

    duracion = time.time() - inicio

    print()
    print(f"Transcripción terminada: {txt_salida.name}")
    print(f"Tiempo aproximado: {duracion / 60:.2f} minutos")

    return txt_salida


def comprobar_ffmpeg() -> None:
    if shutil.which("ffmpeg") is None:
        print(
            "ERROR: FFmpeg no está instalado o no está disponible en PATH.\n"
            "Ejecuta primero el instalador correspondiente:\n"
            "  Windows: scripts\\instalar_whisper.cmd\n"
            "  macOS:   ./scripts/install_whisper.sh",
            file=sys.stderr,
        )
        raise SystemExit(1)


def cargar_whisper():
    try:
        import whisper
    except ImportError:
        print(
            "ERROR: Whisper no está instalado en este entorno.\n"
            "Ejecuta primero el instalador correspondiente.",
            file=sys.stderr,
        )
        raise SystemExit(1)

    return whisper


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Transcribe archivos nuevos desde input/ hacia output/ usando Whisper."
    )

    parser.add_argument(
        "--input",
        default="input",
        help="Carpeta de entrada relativa al root. Por defecto: input",
    )

    parser.add_argument(
        "--output",
        default="output",
        help="Carpeta de salida relativa al root. Por defecto: output",
    )

    parser.add_argument(
        "--modelo",
        default=MODELO_PREDETERMINADO,
        choices=["tiny", "base", "small", "medium", "large"],
        help=f"Modelo Whisper a usar. Por defecto: {MODELO_PREDETERMINADO}",
    )

    parser.add_argument(
        "--idioma",
        default="Spanish",
        help="Idioma del audio. Por defecto: Spanish",
    )

    args = parser.parse_args()

    repo_root = obtener_repo_root()

    input_dir = (repo_root / args.input).resolve()
    output_dir = (repo_root / args.output).resolve()

    if not input_dir.exists():
        print(f"No existe la carpeta de entrada: {input_dir}", file=sys.stderr)
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)

    print("============================================================")
    print("Whisper - Transcripción por lotes")
    print("============================================================")
    print(f"Root:    {repo_root}")
    print(f"Input:   {input_dir}")
    print(f"Output:  {output_dir}")
    print(f"Modelo:  {args.modelo}")
    print(f"Idioma:  {args.idioma}")
    print("============================================================")

    pendientes = encontrar_archivos_pendientes(input_dir, output_dir)

    if not pendientes:
        print()
        print("No hay archivos nuevos para transcribir.")
        print("Si quieres reprocesar un audio, borra su TXT correspondiente en output/.")
        return

    print()
    print(f"Archivos pendientes encontrados: {len(pendientes)}")

    for archivo in pendientes:
        print(f" - {archivo.name}")

    print()
    print(f"Cargando modelo Whisper: {args.modelo}")
    print("La primera ejecución puede descargar el modelo.")
    comprobar_ffmpeg()
    whisper = cargar_whisper()
    model = whisper.load_model(args.modelo)

    procesados = 0
    errores = 0

    for archivo in pendientes:
        try:
            transcribir_archivo(
                archivo=archivo,
                output_dir=output_dir,
                model=model,
                idioma=args.idioma,
            )
            procesados += 1
        except Exception as e:
            errores += 1
            print()
            print(f"ERROR al transcribir {archivo.name}: {e}", file=sys.stderr)

    print()
    print("============================================================")
    print("Resumen")
    print("============================================================")
    print(f"Procesados correctamente: {procesados}")
    print(f"Errores:                  {errores}")
    print("============================================================")

    if errores > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
