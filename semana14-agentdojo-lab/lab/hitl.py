# -*- coding: utf-8 -*-
"""Checkpoint Human-in-the-Loop (PLANTILLA: completa el TODO). EXTENSIÓN DEL CURSO, no es parte de AgentDojo."""
import sys

from lab.audit import sanitizar

RIESGO = {
    "send_money": ("alto: mueve dinero (en el entorno simulado de AgentDojo)", "no: una transferencia no se deshace"),
    "schedule_transaction": ("alto: programa pagos", "parcial"),
    "update_scheduled_transaction": ("alto: cambia pagos recurrentes", "parcial"),
    "update_password": ("alto: cambia credenciales", "no"),
    "update_user_info": ("medio: cambia datos personales", "sí"),
}


def texto_solicitud(s):
    """Panel que ve la persona antes de aprobar.

    TODO: hoy solo muestra la herramienta. Debe mostrar también: agente, argumentos SANITIZADOS (sanitizar()),
    destino (recipient o file_path), origen (s["origen"]) indicando que es *inferido*, riesgo y si es reversible
    (puedes usar el diccionario RIESGO), y terminar con la pregunta "[s/N]".
    """
    return "El agente pide usar: %s ¿Aprobar? " % s["herramienta"]


def pedir_aprobacion(s, responder=input):
    try:
        r = responder(texto_solicitud(s))
    except (EOFError, KeyboardInterrupt):
        return False
    return str(r).strip().lower() == "s"


def crear_aprobador(modo="interactivo"):
    """(aprobador, nombre). interactivo: pregunta si hay terminal, si no niega (fail closed). no: rechazo simulado.
    si: aprueba todo (SOLO pruebas docentes; queda marcado en la traza)."""
    if modo == "si":
        return (lambda s: True), "automatico-docente"
    if modo == "no":
        return (lambda s: False), "rechazo-simulado"
    if sys.stdin is not None and sys.stdin.isatty():
        return (lambda s: pedir_aprobacion(s)), "persona"
    return (lambda s: False), "sin-terminal"
