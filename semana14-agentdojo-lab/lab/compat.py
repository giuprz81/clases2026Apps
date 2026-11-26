# -*- coding: utf-8 -*-
"""Adaptación MÍNIMA y trazable de mensajes OpenAI -> endpoint compatible de Ollama (sin dependencias).

AgentDojo (OpenAILLM) envía:
  1. el mensaje de sistema con rol "developer"  -> aquí se convierte a "system";
  2. el contenido como lista de partes {"type": "text", "text": ...}  -> aquí se aplana a texto;
Además, si el endpoint no devuelve id en un tool_call, el adaptador le asigna uno (lab/adaptador.py),
porque AgentDojo lo exige para reconstruir el historial.
No se cambia el bucle de AgentDojo, ni sus herramientas, ni sus evaluadores.
"""


def _a_texto(contenido):
    if contenido is None:
        return ""
    if isinstance(contenido, str):
        return contenido
    partes = []
    for p in contenido:
        if isinstance(p, dict):
            partes.append(str(p.get("text") or p.get("content") or ""))
        else:
            partes.append(str(p))
    return "\n".join(x for x in partes if x)


def aplanar_mensajes(mensajes):
    salida = []
    for m in mensajes:
        n = dict(m)
        if n.get("role") == "developer":
            n["role"] = "system"
        n["content"] = _a_texto(n.get("content"))
        salida.append(n)
    return salida
