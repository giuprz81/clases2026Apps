# -*- coding: utf-8 -*-
"""Motor de políticas allow/ask/deny (PLANTILLA: completa los TODO).

EXTENSIÓN DEL CURSO: AgentDojo no trae este motor. Se inserta en su pipeline mediante un ToolsExecutor vigilado
(lab/guardian.py): el modelo solo PROPONE la llamada; esta función decide antes de que la herramienta se ejecute.
"""
import json
from pathlib import Path

from lab.escenario import HERRAMIENTAS_BANKING

DECISIONES = ("allow", "ask", "deny")


def cargar_politica(ruta):
    with open(Path(ruta), encoding="utf-8") as f:
        pol = json.load(f)
    if pol.get("default") not in DECISIONES:
        raise ValueError("la política necesita 'default' en allow/ask/deny")
    return pol


def _cumple(cond, args):
    """¿Los argumentos cumplen las condiciones 'when' de una regla?

    TODO 1: implementa las condiciones (si una condición no aparece, no restringe):
      - "recipient_in": lista de IBAN permitidos; compara args["recipient"] sin distinguir mayúsculas.
      - "max_amount": args["amount"] debe ser <= max_amount (si amount no es numérico, NO cumple).
      - "file_in": args["file_path"] debe estar en la lista.
    """
    return True


def _regla_aplica(regla, herramienta, args):
    return regla.get("tool") == herramienta and _cumple(regla.get("when", {}), args)


def decidir(politica, herramienta, args):
    """Devuelve (decision, indice_regla|None). La primera regla que aplica decide.

    TODO 2: una herramienta que no está en HERRAMIENTAS_BANKING debe ser "deny".
    TODO 3: una decisión que no esté en DECISIONES debe tratarse como "deny".
    """
    for i, regla in enumerate(politica.get("rules", [])):
        if _regla_aplica(regla, herramienta, args):
            return regla.get("decision", "deny"), i
    return politica.get("default", "deny"), None
