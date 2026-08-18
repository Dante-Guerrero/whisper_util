# WHISPER_UTIL

Utilidad local para transcribir archivos de audio o video usando Whisper.

El proyecto está organizado para colocar archivos en la carpeta `input/`, ejecutar un script, y obtener las transcripciones en formato `.txt` dentro de la carpeta `output/`.

## Estructura del proyecto

```text
WHISPER_UTIL/
├─ .venv/
├─ input/
│  └─ archivos de audio o video
├─ output/
│  └─ transcripciones generadas
├─ scripts/
│  ├─ instalar_whisper.cmd
│  ├─ install_whisper.ps1
│  └─ transcribir_input.cmd
├─ src/
│  └─ transcribir_whisper.py
└─ .gitignore
```

## Requisitos

Este proyecto está pensado para Windows.

El instalador se encarga de verificar o instalar:

- Python
- FFmpeg
- Whisper
- Entorno virtual `.venv`

## Instalación

Para instalar Whisper y sus dependencias, ejecutar:

```powershell
scripts\instalar_whisper.cmd
```

También se puede ejecutar haciendo doble clic sobre:

```text
scripts/instalar_whisper.cmd
```

El instalador creará un entorno virtual en la carpeta:

```text
.venv/
```

Si Python o FFmpeg son instalados durante el proceso, puede ser necesario cerrar y volver a abrir la terminal antes de ejecutar nuevamente el instalador.

## Uso básico

1. Colocar los archivos de audio o video dentro de la carpeta:

```text
input/
```

Ejemplo:

```text
input/alejo_mexcom.mp4
```

2. Ejecutar el transcriptor:

```powershell
scripts\transcribir_input.cmd
```

También se puede ejecutar haciendo doble clic sobre:

```text
scripts/transcribir_input.cmd
```

3. Revisar la transcripción generada en:

```text
output/
```

Ejemplo:

```text
output/alejo_mexcom.txt
```

## Funcionamiento

El script revisa los archivos ubicados en `input/` y genera una transcripción `.txt` en `output/`.

Por ejemplo:

```text
input/alejo_mexcom.mp4
```

genera:

```text
output/alejo_mexcom.txt
```

## Detección de archivos nuevos

El script solo transcribe archivos que todavía no tengan una transcripción correspondiente en `output/`.

Por ejemplo, si existe:

```text
output/alejo_mexcom.txt
```

entonces el archivo:

```text
input/alejo_mexcom.mp4
```

será omitido en la siguiente ejecución.

## Reprocesar un archivo

Para volver a transcribir un archivo, basta con borrar su `.txt` correspondiente en `output/`.

Ejemplo:

```text
output/alejo_mexcom.txt
```

Luego ejecutar nuevamente:

```powershell
scripts\transcribir_input.cmd
```

El script detectará que falta la transcripción y volverá a procesar el archivo original en `input/`.

## Formatos soportados

El script reconoce archivos con estas extensiones:

```text
.mp3
.wav
.m4a
.aac
.ogg
.flac
.wma
.mp4
.mov
.mkv
.avi
.webm
```

## Modelo usado por defecto

El lanzador usa por defecto el modelo:

```text
small
```

y el idioma:

```text
Spanish
```

Esta configuración se encuentra en:

```text
scripts/transcribir_input.cmd
```

En particular, en esta línea:

```bat
".venv\Scripts\python.exe" "src\transcribir_whisper.py" --input input --output output --modelo small --idioma Spanish
```

## Cambiar el modelo de Whisper

Para usar un modelo más rápido, modificar `small` por:

```text
tiny
base
```

Para usar modelos más precisos, pero más lentos, modificar `small` por:

```text
medium
large
```

Ejemplo:

```bat
".venv\Scripts\python.exe" "src\transcribir_whisper.py" --input input --output output --modelo medium --idioma Spanish
```

## Ejecución manual desde terminal

También se puede ejecutar directamente desde el entorno virtual:

```powershell
.\.venv\Scripts\python.exe src\transcribir_whisper.py --input input --output output --modelo small --idioma Spanish
```

## Recomendación de uso

Para una ThinkPad sin GPU dedicada, se recomienda comenzar con:

```text
small
```

Si el procesamiento tarda demasiado, usar:

```text
base
```

Si se requiere mayor precisión y no importa esperar más tiempo, usar:

```text
medium
```

