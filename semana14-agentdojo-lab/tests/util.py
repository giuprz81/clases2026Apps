import importlib.util
import shutil
import tempfile
import unittest
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
HAY_AGENTDOJO = importlib.util.find_spec("agentdojo") is not None
MENSAJE = ("AgentDojo NO está instalado: esta prueba no puede ejecutarse y NO cuenta como aprobada. "
           "Instala con: pip install -r requirements.txt")


def requiere_agentdojo(cls):
    """Si falta AgentDojo, la prueba FALLA con un mensaje claro (no se omite: una omisión no es una aprobación)."""
    if not HAY_AGENTDOJO:
        def setUp(self):
            self.fail(MENSAJE)
        cls.setUp = setUp
    return cls


def proyecto_temporal():
    tmp = Path(tempfile.mkdtemp(prefix="adlab_"))
    for d in ("politicas", "payloads", "rubric"):
        shutil.copytree(RAIZ / d, tmp / d)
    for d in ("trazas", "evaluacion"):
        (tmp / "outputs" / d).mkdir(parents=True)
    return tmp
