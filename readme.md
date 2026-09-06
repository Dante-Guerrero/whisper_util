# WHISPER_UTIL

Utilidad local y multiplataforma para transcribir archivos de audio o video con Python, [OpenAI Whisper](https://github.com/openai/whisper) y FFmpeg. Funciona en Windows 10/11 y en macOS Intel o Apple Silicon.

Los archivos se colocan en `input/` y las transcripciones `.txt` se guardan en `output/`. Si el `.txt` correspondiente ya existe, el archivo se omite; para reprocesarlo basta con borrar ese `.txt`.

## Windows

Instala Python, FFmpeg y las dependencias ejecutando o abriendo con doble clic:

```bat
scripts\instalar_whisper.cmd
```

Después coloca los archivos en `input\` y ejecuta:

```bat
main.cmd
```

El instalador prefiere el lanzador `py`, usa `winget` cuando necesita instalar Python o FFmpeg y crea `.venv` en el repositorio. Si acaba de instalar una herramienta y todavía no aparece en `PATH`, reinicia la terminal y vuelve a ejecutar el instalador.

## macOS

Desde Terminal, instala las dependencias con:

```bash
./scripts/install_whisper.sh
```

Después coloca los archivos en `input/` y ejecuta:

```bash
./main.command
```

`main.command` también puede abrirse desde Finder. Si macOS no permite ejecutarlo inicialmente, abre Terminal en el repositorio y ejecuta:

```bash
chmod +x main.command scripts/install_whisper.sh
```

El instalador detecta Homebrew tanto en `/opt/homebrew` (Apple Silicon) como en `/usr/local` (Intel), y utiliza una versión compatible de Python 3. Si Homebrew no existe, muestra cómo instalarlo y se detiene sin modificar la configuración del usuario.

## Uso y configuración

Los valores predeterminados están centralizados en `src/transcribir_whisper.py`:

- modelo: `large`;
- idioma: `Spanish`;
- entrada: `input/`;
- salida: `output/`.

La primera ejecución de `large` puede descargar varios GB. Este modelo consume más memoria y tarda más que `small` o `medium`; en equipos con recursos limitados puede elegirse otro mediante `--modelo`. Los pesos no se guardan en este repositorio.

Para personalizar la ejecución, usa directamente el intérprete del entorno virtual.

Windows:

```bat
.venv\Scripts\python.exe src\transcribir_whisper.py --modelo medium --idioma English
```

macOS:

```bash
.venv/bin/python src/transcribir_whisper.py --modelo medium --idioma English
```

También están disponibles `--input` y `--output`. Consulta todas las opciones con `--help`.

## Archivos admitidos

`.mp3`, `.opus`, `.wav`, `.m4a`, `.aac`, `.ogg`, `.flac`, `.wma`, `.mp4`, `.mov`, `.mkv`, `.avi` y `.webm`.

Ejemplo: `input/entrevista.mp4` genera `output/entrevista.txt`. Si `output/entrevista.txt` ya existe, se omite; bórralo y vuelve a ejecutar el lanzador para reprocesar el original.

## Estructura

```text
WHISPER_UTIL/
├── input/
├── output/
├── scripts/
│   ├── instalar_whisper.cmd
│   ├── install_whisper.ps1
│   ├── install_whisper.sh
│   └── transcribir_input.cmd
├── src/
│   └── transcribir_whisper.py
├── main.cmd
├── main.command
└── requirements.txt
```
