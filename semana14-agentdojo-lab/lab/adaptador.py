# -*- coding: utf-8 -*-
"""Adaptador OpenAI-compatible para los endpoints Ollama del docente, sobre la clase OFICIAL OpenAILLM de AgentDojo.

Usa las funciones internas del propio AgentDojo (agentdojo.agent_pipeline.llms.openai_llm) para convertir mensajes,
herramientas y respuestas; solo aplica la adaptación mínima de lab/compat.py (rol system, texto plano, ids).
"""
import openai
from agentdojo.agent_pipeline import OpenAILLM
from agentdojo.agent_pipeline.llms import openai_llm as OL
from agentdojo.functions_runtime import EmptyEnv

from lab.compat import aplanar_mensajes
from lab.config import validar_url


class OllamaCompatLLM(OpenAILLM):
    """OpenAILLM de AgentDojo + adaptación mínima para Ollama. El bucle y las herramientas siguen siendo los de AgentDojo."""

    def query(self, query, runtime, env=EmptyEnv(), messages=[], extra_args={}):
        mensajes = aplanar_mensajes([OL._message_to_openai(m, self.model) for m in messages])
        herramientas = [OL._function_to_openai(t) for t in runtime.functions.values()]
        completion = OL.chat_completion_request(self.client, self.model, mensajes, herramientas,
                                                self.reasoning_effort, self.temperature)
        salida = OL._openai_to_assistant_message(completion.choices[0].message)
        for i, tc in enumerate(salida["tool_calls"] or []):
            if not tc.id:
                tc.id = "call_%d_%d" % (len(messages), i)
        return query, runtime, env, [*messages, salida], extra_args


def crear_llm(url, modelo, clave, timeout=45):
    validar_url(url)
    if not clave:
        raise ValueError("faltan credenciales para el modo live (revisa tu .env): usa --modo mock")
    cliente = openai.OpenAI(base_url=url, api_key=clave, timeout=timeout, max_retries=1)
    return OllamaCompatLLM(cliente, modelo, temperature=0.0)
