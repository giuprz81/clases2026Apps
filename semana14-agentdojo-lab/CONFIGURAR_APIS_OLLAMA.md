# Configurar las APIs de los modelos Ollama en VS Code (Windows)

Hazlo **antes de la clase**. Nunca envíes tus claves al chat, a Claude, a GitHub, a capturas ni a la entrega.

| Rol | Modelo | Base URL (compatible con OpenAI) | Variable de clave |
|---|---|---|---|
| Agente bajo prueba | `llama3.1:8b` | `https://ec11t2557.tail7e0f77.ts.net/llama/v1` | `LLAMA_API_KEY` |
| Juez | `qwen3-next:80b` | `https://ec11t2557.tail7e0f77.ts.net/qwen/v1` | `QWEN_API_KEY` |

Son modelos servidos por **Ollama en el servidor del docente**; no son modelos de OpenAI ni de Anthropic. Las URLs son **fijas** (no cambian al reiniciar el servidor). Para que respondan, el servidor del docente debe estar encendido.

## Paso 1. Abrir el proyecto e instalar

1. En VS Code: **Archivo > Abrir carpeta** y elige la carpeta raíz `semana14-agentdojo-lab` (la que contiene `README.md`, `.gitignore`, `.env.example` y `lab/`).
2. **Terminal > Nueva terminal** (PowerShell).
3. Crea y activa el entorno, e instala (una sola vez):

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Si PowerShell bloquea la activación, ejecuta una vez `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` y vuelve a activar.

## Paso 2. Crear tu archivo `.env`

1. En el explorador de VS Code, clic derecho sobre `.env.example` > **Copiar** y luego **Pegar** en la **misma carpeta raíz**.
2. Renombra la copia a `.env` (exactamente así, sin `.txt`). Debe quedar junto a `README.md` y `.gitignore`, **no** dentro de `lab/`.
3. Abre `.env` y deja estas líneas (cambia `LAB_MODE` a `live`):

```ini
LLAMA_BASE_URL=https://ec11t2557.tail7e0f77.ts.net/llama/v1
LLAMA_MODEL=llama3.1:8b
LLAMA_API_KEY=REEMPLAZAR_LOCALMENTE
QWEN_BASE_URL=https://ec11t2557.tail7e0f77.ts.net/qwen/v1
QWEN_MODEL=qwen3-next:80b
QWEN_API_KEY=REEMPLAZAR_LOCALMENTE
LAB_MODE=live
LAB_JUEZ_LIVE=1
```

4. Sustituye **solo en tu `.env`** los dos `REEMPLAZAR_LOCALMENTE` por la clave de Llama y la de Qwen que te dio el docente (son distintas). Sin comillas ni espacios.
5. Guarda con **Ctrl+S**. No modifiques `.env.example`: ese archivo sí se comparte.

## Paso 3. Comprobar que `.env` no se sube a Git

```powershell
git status
```

`.env` **no** debe aparecer. El `.gitignore` del proyecto ya lo excluye. Si alguna vez subiste `.env` a un repositorio, avisa al docente para **revocar** esas claves; no basta con borrarlo.

## Paso 4. Verificar la configuración (no prueba conexión)

```powershell
python -m lab preflight
```

Debe mostrar `.env en la raíz: sí`, `Modo configurado: live` y, para ambos modelos, `URL: definida | clave: definida`. Esto **solo** confirma que se leyó la configuración. Si dice `mock`, revisa `LAB_MODE` en `.env`; si una clave aparece «vacía», revisa el nombre exacto y que guardaste. Una variable de entorno de Windows con el mismo nombre tiene prioridad sobre `.env`.

## Paso 5. Probar los endpoints reales

```powershell
python -m lab smoke-live
```

Hace tres comprobaciones por separado, sin imprimir claves:

1. **Llama: conexión y autenticación.**
2. **Llama: tool calling estructurado** (que el modelo devuelva una llamada de herramienta, necesaria para AgentDojo).
3. **Qwen: conexión y autenticación.**

| Mensaje | Qué significa |
|---|---|
| `autenticacion` (HTTP 401/403) | clave rechazada o sin permiso: revisa la clave en `.env` |
| `ruta_o_modelo` (HTTP 404) | URL o nombre del modelo incorrecto |
| `dns` / `conexion` | servidor del docente apagado o sin red, firewall o URL mal escrita |
| `ssl` | problema de certificado o de proxy |
| `timeout` / `saturacion` / `servidor` | servidor o GPU ocupados: espera o usa mock |
| `sin tool_calls estructuradas` | el endpoint no permite usar herramientas: usa mock y avisa al docente |

Un fallo de red, del servidor o de saturación **no** significa que el modelo sea seguro ni vulnerable.

## Paso 6. Usar el modo live

Solo si el smoke pasó, añade `--modo live` a cada comando, por ejemplo:

```powershell
python -m lab baseline --modo live --aprobar interactivo
python -m lab attack --modo live --payload payloads/payload_estudiante.txt --etiqueta red
python -m lab evaluate --modo live
```

Sin `--modo live` el laboratorio sigue en **mock** aunque `.env` diga `live`. El juez live solo corre si Qwen respondió y `LAB_JUEZ_LIVE=1`. Si algo falla, trabaja en mock y escríbelo en tus evidencias (mock **no** prueba los endpoints reales).
