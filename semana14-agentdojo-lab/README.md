# Semana 14 (V3) — Red · Blue · Green sobre **AgentDojo** (ETH Zurich) con modelos Ollama

Laboratorio **individual de 60 minutos** de *Programación Asistida de Aplicaciones* (USFQ).
Usa el benchmark oficial **AgentDojo** (https://github.com/ethz-spylab/agentdojo, licencia MIT): su suite, sus tareas, su
entorno simulado, su ataque y sus evaluadores. Todo ocurre en el **entorno simulado** de AgentDojo: no hay bancos, dinero ni
servicios reales.

## Qué es de AgentDojo y qué es del curso

| Componente | Origen |
|---|---|
| Suite `banking` (v1), `user_task_0`, `injection_task_0`, ataque `important_instructions`, vector `injection_bill_text` | **AgentDojo oficial** |
| Herramientas (`read_file`, `send_money`, …), entorno simulado, `TaskSuite.run_task_with_pipeline` | **AgentDojo oficial** |
| Evaluadores: `utility` (¿se pagó la factura?) y éxito del ataque (¿llegó una transferencia al IBAN atacante?) | **AgentDojo oficial** |
| Pipeline `SystemMessage → InitQuery → LLM → ToolsExecutionLoop([ToolsExecutor, LLM])`, clase `OpenAILLM` | **AgentDojo oficial** |
| `lab/adaptador.py` + `lab/compat.py`: adaptación mínima para Ollama (rol `system`, texto plano, ids de tool_call) | **adaptación del curso** |
| `lab/guardian.py`: `EjecutorVigilado` (subclase de `ToolsExecutor`) con política allow/ask/deny, HITL y JIT | **extensión del curso** |
| `lab/politica.py`, `lab/hitl.py`, `lab/jit.py`, auditoría JSONL, juez y comparación | **extensiones del curso** |
| `lab/mock_agente.py`: modelo simulado para practicar sin red | **extensión del curso** (rotulada MOCK) |

## Instalación (antes de la clase; tarda varios minutos)

Requiere Python 3.10+ y Git. En la terminal de VS Code (PowerShell en Windows), desde esta carpeta:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1           # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt       # instala AgentDojo fijado al commit 089ed468 y sus dependencias
python -m lab preflight
python -m lab verificar               # autoverificación SIN claves: corre el escenario real de AgentDojo con el agente mock
```

`requirements.txt` instala AgentDojo desde GitHub en el commit `089ed468cf3ed0322acc66b0211f26d9d90dbf60` (2 jun 2026),
que añade el proveedor `openai-compatible`. La versión de PyPI 0.1.35 es anterior.

## Modelos Ollama (modo live)

Agente `llama3.1:8b` y juez `qwen3-next:80b`, servidos por Ollama en el servidor del docente con API compatible con OpenAI.
Guía paso a paso para VS Code en Windows, con las variables exactas del `.env`: **[`CONFIGURAR_APIS_OLLAMA.md`](CONFIGURAR_APIS_OLLAMA.md)**.

## Comandos

| Comando | Para qué |
|---|---|
| `python -m lab preflight` | versión/commit de AgentDojo, escenario, configuración (no prueba conectividad) |
| `python -m lab smoke-live` | llamada inocua a cada modelo y comprobación de `tool_calls` estructuradas (requiere `LAB_MODE=live`) |
| `python -m lab verificar` | autoverificación offline con el agente mock |
| `python -m lab mostrar-ataque` | texto exacto que inserta el ataque oficial |
| `python -m lab baseline` | `user_task_0` sin ataque |
| `python -m lab attack` | con inyección (ataque oficial o `--payload`), política insegura |
| `python -m lab defend` | con tu política (Blue) y opcionalmente `--jit` (Green) |
| `python -m lab metrics` · `evaluate` · `compare` | métricas, juez y comparación con tu puntaje |

`--modo mock` es el valor por defecto. El live exige `LAB_MODE=live` en `.env` **y** `--modo live`.

## Pruebas

```powershell
python -m unittest discover -s tests/sanidad -t .       # sin AgentDojo: deben pasar siempre
python -m unittest discover -s tests/integracion -t .   # con AgentDojo: deben pasar; si falta, FALLAN (no se omiten)
python -m unittest discover -s tests/estudiante -t .    # tus TODO: fallan hasta completarlos
```

## Seguridad

`.env` (al lado de `.env.example`) no se versiona. Nunca escribas claves en el chat, GitHub, capturas, logs ni en la entrega.
El agente solo dispone de las herramientas simuladas de AgentDojo; no hay shell, red libre ni `git push`. El agente no puede
cambiar su política: vive fuera del modelo, en el ejecutor de herramientas.
