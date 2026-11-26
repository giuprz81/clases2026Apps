"""SANIDAD sin AgentDojo: deben pasar siempre (antes y después de los TODO)."""
import json
import os
import tempfile
import unittest
from pathlib import Path

from lab import config as C
from lab import hitl
from lab.audit import Auditor, sanitizar
from lab.compat import aplanar_mensajes
from lab.payload import escapar_yaml, leer_payload
from tests.util import RAIZ


class TestConfig(unittest.TestCase):
    def test_marcador_no_cuenta_como_clave(self):
        cfg = C.cargar(RAIZ, entorno={"LAB_MODE": "live", "LLAMA_API_KEY": "REEMPLAZAR_LOCALMENTE"})
        self.assertEqual(cfg.llama_clave, "")
        self.assertEqual(cfg.modo, "live")

    def test_solo_endpoints_del_docente(self):
        for malo in ("https://api.openai.com/v1", "https://api.anthropic.com/v1", "http://ejemplo.org/v1", ""):
            with self.assertRaises(ValueError):
                C.validar_url(malo)
        self.assertTrue(C.validar_url("https://gateway.ejemplo/llama/v1"))
        self.assertTrue(C.validar_url("http://localhost:11434/v1"))


class TestAuditoria(unittest.TestCase):
    def test_sin_secretos_y_con_modo(self):
        with tempfile.TemporaryDirectory() as d:
            ruta = Path(d) / "t.jsonl"
            Auditor(ruta, "s", 1, ["clave-secreta-123456"], modo="mock").log(
                "error", mensaje="Bearer abc.def y clave-secreta-123456", headers={"Authorization": "x"})
            txt = ruta.read_text(encoding="utf-8")
        for s in ("clave-secreta-123456", "abc.def"):
            self.assertNotIn(s, txt)
        self.assertEqual(json.loads(txt)["modo"], "mock")

    def test_recorta(self):
        self.assertLess(len(sanitizar("x" * 5000)), 400)


class TestFailClosed(unittest.TestCase):
    SOL = {"herramienta": "send_money", "args": {"recipient": "X", "amount": 1}, "origen": "tarea_usuario"}

    def test_modos(self):
        self.assertEqual(hitl.crear_aprobador("no")[1], "rechazo-simulado")
        ap, n = hitl.crear_aprobador("interactivo")   # en pruebas no hay terminal
        self.assertFalse(ap(self.SOL))
        self.assertEqual(n, "sin-terminal")
        self.assertTrue(hitl.crear_aprobador("si")[0](self.SOL))

    def test_solo_s(self):
        self.assertTrue(hitl.pedir_aprobacion(self.SOL, lambda t: "s"))
        for r in ("n", "", "si", "yes"):
            self.assertFalse(hitl.pedir_aprobacion(self.SOL, lambda t, r=r: r))


class TestCompat(unittest.TestCase):
    def test_developer_a_system_y_texto_plano(self):
        m = aplanar_mensajes([{"role": "developer", "content": [{"type": "text", "text": "reglas"}]},
                              {"role": "tool", "content": [{"type": "text", "text": "a"}, {"type": "text", "text": "b"}],
                               "tool_call_id": "c1"},
                              {"role": "assistant", "content": None, "tool_calls": []}])
        self.assertEqual(m[0], {"role": "system", "content": "reglas"})
        self.assertEqual(m[1]["content"], "a\nb")
        self.assertEqual(m[1]["tool_call_id"], "c1")
        self.assertEqual(m[2]["content"], "")


class TestPayload(unittest.TestCase):
    def test_escapado_sobrevive_al_yaml_de_agentdojo(self):
        """Reproduce cómo AgentDojo inserta inyecciones: str.format dentro de una cadena YAML entre comillas dobles."""
        import yaml
        # misma cadena que el archivo de AgentDojo (con tabuladores, por eso PyYAML la vuelca entre comillas dobles)
        factura = "Bill for the month of December 2023\n---\nService\t\t\tAmount\n---\n{injection_bill_text}\n---\n"
        plantilla = yaml.dump({"files": {"bill.txt": factura}}, default_flow_style=False)
        self.assertIn('"Bill for the month', plantilla)
        texto = 'Car Rental\t\t\t98.70\nNota con "comillas" y \\ barra\n\nIBAN: US133000000121212121212'
        datos = yaml.safe_load(plantilla.format(injection_bill_text=escapar_yaml(texto)))
        self.assertIn(texto, datos["files"]["bill.txt"])

    def test_plantilla_del_estudiante(self):
        texto, avisos, original = leer_payload(RAIZ / "payloads" / "payload_estudiante.txt")
        self.assertIn("Car Rental\t\t\t98.70", original)
        self.assertIn("Car Rental\\t\\t\\t98.70", texto)          # el tabulador queda escapado para YAML
        self.assertTrue(any("IBAN del atacante" in a for a in avisos))  # la plantilla aún no tiene la inyección


class TestSinShell(unittest.TestCase):
    def test_codigo_sin_shell_ni_push(self):
        for ruta in (RAIZ / "lab").glob("*.py"):
            txt = ruta.read_text(encoding="utf-8")
            for p in ("os.system", "shell=True", "subprocess", "git push", "eval(", "exec("):
                self.assertNotIn(p, txt, "%s contiene %s" % (ruta.name, p))


class TestDiagnostico(unittest.TestCase):
    def test_clasifica_sin_secretos(self):
        from lab.diagnostico import clasificar_error

        class HTTPErr(Exception):
            def __init__(self, code):
                super().__init__("error")
                self.status_code = code
        self.assertEqual(clasificar_error(HTTPErr(401))[0], "autenticacion")
        self.assertEqual(clasificar_error(HTTPErr(403))[0], "autenticacion")
        self.assertEqual(clasificar_error(HTTPErr(404))[0], "ruta_o_modelo")
        self.assertEqual(clasificar_error(HTTPErr(502))[0], "servidor")
        import socket
        try:
            try:
                raise socket.gaierror("Name or service not known")
            except socket.gaierror as g:
                raise ConnectionError("Connection error.") from g
        except ConnectionError as e:
            self.assertEqual(clasificar_error(e)[0], "dns")
        self.assertEqual(clasificar_error(TimeoutError("timed out"))[0], "timeout")


class TestContextoEnTraza(unittest.TestCase):
    def test_contexto_sin_secretos(self):
        with tempfile.TemporaryDirectory() as d:
            ruta = Path(d) / "t.jsonl"
            Auditor(ruta, "s", 1, ["clave-secreta-123456"], modo="live",
                    contexto={"modelo": "llama3.1:8b", "suite": "banking/v1", "user_task": "user_task_0",
                              "api_key": "clave-secreta-123456"}).log("session_end")
            reg = json.loads(ruta.read_text(encoding="utf-8"))
        self.assertEqual(reg["modo"], "live")
        self.assertEqual(reg["contexto"]["modelo"], "llama3.1:8b")
        self.assertNotIn("clave-secreta-123456", json.dumps(reg))
