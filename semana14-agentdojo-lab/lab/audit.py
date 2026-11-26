# -*- coding: utf-8 -*-
"""Auditoría JSONL sanitizada (EXTENSIÓN DEL CURSO, no es parte de AgentDojo). Nunca escribe claves ni tokens."""
import json
import re
from datetime import datetime, timezone
from pathlib import Path

EVENTOS = ("requested", "authorized", "denied", "approval_requested", "approved", "rejected", "executed",
           "error", "resultado_benchmark", "session_end")

_CLAVE_SENSIBLE = re.compile(r"(authorization|api[_-]?key|secret|password|passwd|bearer)", re.I)
_PATRONES = [re.compile(r"Bearer\s+[A-Za-z0-9._~+/=-]+", re.I), re.compile(r"\bsk-[A-Za-z0-9_-]{8,}")]
MAX_TEXTO = 300


def sanitizar(valor, claves_conocidas=()):
    """Enmascara claves y recorta textos largos. Devuelve una copia segura."""
    if isinstance(valor, dict):
        return {k: ("[REDACTED]" if _CLAVE_SENSIBLE.search(str(k)) else sanitizar(v, claves_conocidas))
                for k, v in valor.items()}
    if isinstance(valor, (list, tuple)):
        return [sanitizar(v, claves_conocidas) for v in valor]
    if isinstance(valor, str):
        for p in _PATRONES:
            valor = p.sub("[REDACTED]", valor)
        for c in claves_conocidas:
            valor = valor.replace(c, "[REDACTED]")
        return valor if len(valor) <= MAX_TEXTO else valor[:MAX_TEXTO] + "…[recortado]"
    return valor


class Auditor:
    """Escribe un evento por línea. El intento bloqueado se registra ANTES de despachar."""

    def __init__(self, ruta, sesion, run=1, claves_conocidas=(), modo="mock", contexto=None):
        self.ruta = Path(ruta)
        self.ruta.parent.mkdir(parents=True, exist_ok=True)
        self.sesion, self.run, self.seq = sesion, run, 0
        self.claves = list(claves_conocidas)
        self.modo = modo  # "mock" o "live": queda en CADA evento para que nunca se confundan
        self.contexto = dict(contexto or {})  # modelo, suite, user_task, injection_task, ataque (sin secretos)

    def log(self, evento, **campos):
        if evento not in EVENTOS:
            raise ValueError("evento de auditoría desconocido: %s" % evento)
        self.seq += 1
        reg = {"ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"), "sesion": self.sesion,
               "run": self.run, "seq": self.seq, "modo": self.modo, "evento": evento}
        if self.contexto:
            reg["contexto"] = sanitizar(self.contexto, self.claves)
        reg.update(sanitizar(campos, self.claves))
        with open(self.ruta, "a", encoding="utf-8") as f:
            f.write(json.dumps(reg, ensure_ascii=False) + "\n")
        return reg


def leer_traza(ruta):
    ruta = Path(ruta)
    if not ruta.is_file():
        return []
    with open(ruta, encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]


def siguiente_run(ruta):
    ev = leer_traza(ruta)
    return (max((e.get("run", 0) for e in ev), default=0)) + 1
