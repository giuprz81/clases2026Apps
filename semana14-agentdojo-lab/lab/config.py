# -*- coding: utf-8 -*-
"""Lee variables del sistema y el .env local (lector propio). Las variables del sistema tienen prioridad."""
import os
from dataclasses import dataclass, field
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
MARCADOR = "REEMPLAZAR_LOCALMENTE"


def _leer_env(ruta):
    datos = {}
    if ruta.is_file():
        for linea in ruta.read_text(encoding="utf-8").splitlines():
            linea = linea.strip()
            if linea and not linea.startswith("#") and "=" in linea:
                k, v = linea.split("=", 1)
                datos[k.strip()] = v.strip().strip('"').strip("'")
    return datos


@dataclass
class Config:
    raiz: Path
    modo: str = "mock"
    llama_url: str = ""
    llama_modelo: str = "llama3.1:8b"
    llama_clave: str = field(default="", repr=False)
    qwen_url: str = ""
    qwen_modelo: str = "qwen3-next:80b"
    qwen_clave: str = field(default="", repr=False)
    juez_live: bool = True

    @property
    def trazas(self):
        return self.raiz / "outputs" / "trazas"

    @property
    def evaluacion(self):
        return self.raiz / "outputs" / "evaluacion"

    def claves_conocidas(self):
        return [c for c in (self.llama_clave, self.qwen_clave) if c and c != MARCADOR and len(c) >= 6]


def cargar(raiz=None, entorno=None):
    raiz = Path(raiz) if raiz else RAIZ
    env = dict(_leer_env(raiz / ".env"))
    env.update(os.environ if entorno is None else entorno)
    g = lambda k, d="": env.get(k, d)
    clave = lambda k: "" if g(k) == MARCADOR else g(k)
    modo = g("LAB_MODE", "mock").lower()
    return Config(raiz=raiz, modo=modo if modo in ("mock", "live") else "mock",
                  llama_url=g("LLAMA_BASE_URL"), llama_modelo=g("LLAMA_MODEL", "llama3.1:8b"), llama_clave=clave("LLAMA_API_KEY"),
                  qwen_url=g("QWEN_BASE_URL"), qwen_modelo=g("QWEN_MODEL", "qwen3-next:80b"), qwen_clave=clave("QWEN_API_KEY"),
                  juez_live=g("LAB_JUEZ_LIVE", "1").strip().lower() not in ("0", "false", "no"))


def validar_url(url):
    """Solo endpoints del docente: https (o local). Nunca APIs alojadas de OpenAI/Anthropic."""
    from urllib.parse import urlparse
    u = urlparse(url or "")
    if not u.hostname:
        raise ValueError("falta la URL base del modelo")
    if (u.hostname or "").endswith(("openai.com", "anthropic.com")):
        raise ValueError("este laboratorio solo usa los endpoints Ollama del docente")
    if u.scheme != "https" and u.hostname not in ("127.0.0.1", "localhost", "::1"):
        raise ValueError("la URL debe usar https (o ser local)")
    return url
