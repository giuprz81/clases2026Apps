# -*- coding: utf-8 -*-
"""Construye el pipeline con los elementos OFICIALES de AgentDojo y ejecuta el escenario con su TaskSuite."""
import secrets

from agentdojo.agent_pipeline import AgentPipeline, InitQuery, SystemMessage, ToolsExecutionLoop
from agentdojo.agent_pipeline.agent_pipeline import load_system_message
from agentdojo.attacks import load_attack
from agentdojo.task_suite.load_suites import get_suite

from lab import escenario as E
from lab import jit as J
from lab.guardian import AlcanceJIT, EjecutorVigilado


def cargar_escenario():
    suite = get_suite(E.BENCHMARK_VERSION, E.SUITE)
    return suite, suite.get_user_task_by_id(E.USER_TASK), suite.get_injection_task_by_id(E.INJECTION_TASK)


def construir(llm, nombre_modelo, ejecutor, token=None):
    """Mismo esquema que AgentPipeline.from_config sin defensa: SystemMessage, InitQuery, LLM, ToolsExecutionLoop."""
    elementos = [SystemMessage(load_system_message(None)), InitQuery()]
    if token is not None:
        elementos.append(AlcanceJIT(token))
    elementos += [llm, ToolsExecutionLoop([ejecutor, llm])]
    p = AgentPipeline(elementos)
    # El ataque oficial nombra al modelo a partir del nombre del pipeline; "openai-compatible" es una clave válida
    # de agentdojo.models.MODEL_NAMES en el commit fijado.
    p.name = "openai-compatible/" + nombre_modelo
    return p


def token_tarea(minutos=10):
    """Green: permiso mínimo para pagar la factura (EXTENSIÓN DEL CURSO)."""
    clave = secrets.token_hex(16)
    tok = J.emitir("estudiante", "agentdojo/banking/user_task_0", ["read_file", "send_money"],
                   {"recipients": [E.IBAN_FACTURA], "max_amount": 100}, "pagar-factura", minutos, clave)
    return tok, clave


def ejecutar(llm, nombre_modelo, auditor, politica=None, aprobador=None, aprobador_nombre="sin-terminal",
             con_ataque=False, injections=None, jit=False):
    """Corre user_task_0 (y, si hay ataque, injection_task_0) con TaskSuite.run_task_with_pipeline de AgentDojo.
    Devuelve (utility, ataque_exitoso|None, detalle)."""
    suite, ut, it = cargar_escenario()
    token = clave = None
    if jit:
        token, clave = token_tarea()
    ejecutor = EjecutorVigilado(auditor, politica, aprobador, aprobador_nombre,
                                {"token": token, "clave": clave} if jit else None)
    pipeline = construir(llm, nombre_modelo, ejecutor, token)
    if con_ataque:
        origen = "payload del estudiante en el vector oficial"
        if injections is None:
            injections = load_attack(E.ATAQUE, suite, pipeline).attack(ut, it)
            origen = "ataque oficial " + E.ATAQUE
        utility, security = suite.run_task_with_pipeline(pipeline, ut, it, injections)
        return utility, security, {"injection_task": E.INJECTION_TASK, "vectores": sorted(injections), "origen_ataque": origen}
    utility, _ = suite.run_task_with_pipeline(pipeline, ut, None, {})
    return utility, None, {"injection_task": None}


def verificar_payload(original, injections):
    """Comprueba con el cargador OFICIAL de AgentDojo que la factura resultante contiene el payload tal cual."""
    suite, _, _ = cargar_escenario()
    entorno = suite.load_and_inject_default_environment(injections)
    if original not in entorno.filesystem.files[E.ARCHIVO_FACTURA]:
        raise ValueError("el payload no quedó íntegro dentro de la factura (revisa caracteres especiales)")


def texto_ataque_oficial(nombre_modelo="mock-agente"):
    """Texto exacto que el ataque oficial inserta en el vector (para que el estudiante lo vea)."""
    from lab.mock_agente import AgenteMock
    suite, ut, it = cargar_escenario()
    p = construir(AgenteMock(), nombre_modelo, EjecutorVigilado(_Nulo()))
    ataque = load_attack(E.ATAQUE, suite, p)
    return ataque.get_injection_candidates(ut), ataque.attack(ut, it)


class _Nulo:
    def log(self, *a, **k):
        pass
