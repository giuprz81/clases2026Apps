# -*- coding: utf-8 -*-
"""Defensas del curso insertadas en el pipeline OFICIAL de AgentDojo (EXTENSIONES DEL CURSO).

- EjecutorVigilado: subclase de agentdojo.agent_pipeline.ToolsExecutor. Antes de ejecutar CADA tool_call aplica
  política allow/ask/deny, checkpoint HITL y token JIT. Lo permitido lo ejecuta el ToolsExecutor original.
  Lo bloqueado devuelve un ChatToolResultMessage con error (la herramienta no se ejecuta) y queda auditado.
- AlcanceJIT: reduce las herramientas visibles al alcance del token (menor privilegio).
"""
from agentdojo.agent_pipeline import BasePipelineElement, ToolsExecutor
from agentdojo.functions_runtime import EmptyEnv
from agentdojo.types import ChatAssistantMessage, ChatToolResultMessage, text_content_block_from_string

from lab import jit as J
from lab import politica as P
from lab.escenario import IBAN_FACTURA

TAREA = ("read_file", "send_money")


class EjecutorVigilado(ToolsExecutor):
    def __init__(self, auditor, politica=None, aprobador=None, aprobador_nombre="sin-terminal", jit=None):
        super().__init__()
        self.aud, self.politica, self.jit = auditor, politica, jit
        self.aprobador = aprobador or (lambda s: False)
        self.aprobador_nombre = aprobador_nombre

    @staticmethod
    def _origen(messages, tc):
        leido = any(m["role"] == "tool" and m["tool_call"].function == "read_file" for m in messages)
        ajena = tc.function not in TAREA or (
            tc.function == "send_money" and str(tc.args.get("recipient", "")).lower() != IBAN_FACTURA.lower())
        return "contenido_no_confiable" if (leido and ajena) else "tarea_usuario"

    def _bloqueo(self, tc, motivo):
        return ChatToolResultMessage(role="tool", content=[text_content_block_from_string("")], tool_call_id=tc.id,
                                     tool_call=tc, error="Bloqueado por el control del laboratorio: " + motivo)

    def query(self, query, runtime, env=EmptyEnv(), messages=[], extra_args={}):
        if not messages or messages[-1]["role"] != "assistant" or not messages[-1]["tool_calls"]:
            return super().query(query, runtime, env, messages, extra_args)
        ultimo, resultados = messages[-1], []
        for tc in ultimo["tool_calls"]:
            base = {"call_id": tc.id, "herramienta": tc.function, "args": dict(tc.args),
                    "origen": self._origen(messages, tc), "origen_inferido": True}
            self.aud.log("requested", **base)
            decision, regla, motivo = "allow", None, "sin política (equivale a la ejecución original de AgentDojo)"
            if self.politica is not None:
                decision, regla = P.decidir(self.politica, tc.function, dict(tc.args))
                motivo = "política"
            if self.jit is not None and decision != "deny":
                ok, m = J.validar(self.jit["token"], tc.function, dict(tc.args), self.jit["clave"])
                if not ok:
                    decision, motivo = "deny", "jit: " + m
            if decision == "deny":
                self.aud.log("denied", **dict(base, decision="deny", regla=regla, motivo=motivo))
                resultados.append(self._bloqueo(tc, motivo))
                continue
            if decision == "ask":
                self.aud.log("approval_requested", **dict(base, decision="ask", regla=regla))
                if not self.aprobador(dict(base, agente="agente-agentdojo")):
                    m = "sin interacción: fail closed" if self.aprobador_nombre == "sin-terminal" else "la persona rechazó"
                    self.aud.log("rejected", **dict(base, aprobado=False, aprobador=self.aprobador_nombre, motivo=m))
                    resultados.append(self._bloqueo(tc, m))
                    continue
                self.aud.log("approved", **dict(base, aprobado=True, aprobador=self.aprobador_nombre,
                                                aprobacion_automatica=self.aprobador_nombre == "automatico-docente"))
            self.aud.log("authorized", **dict(base, decision=decision, regla=regla))
            solo = ChatAssistantMessage(role="assistant", content=ultimo["content"], tool_calls=[tc])
            _, runtime, env, salida, extra_args = super().query(query, runtime, env, [*messages[:-1], solo], extra_args)
            res = salida[-1]
            self.aud.log("executed", **dict(base, entorno="simulado de AgentDojo", error=res["error"]))
            resultados.append(res)
        return query, runtime, env, [*messages, *resultados], extra_args


class AlcanceJIT(BasePipelineElement):
    """Menor privilegio: el modelo solo ve las herramientas concedidas por el token."""

    def __init__(self, token):
        self.token = token

    def query(self, query, runtime, env=EmptyEnv(), messages=[], extra_args={}):
        runtime.update_functions({k: v for k, v in runtime.functions.items() if k in self.token["actions"]})
        return query, runtime, env, messages, extra_args
