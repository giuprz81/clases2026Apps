# -*- coding: utf-8 -*-
"""CLI del laboratorio:  python -m lab <comando>

Comandos: preflight · smoke-live · verificar · mostrar-ataque · baseline · attack · defend · metrics · evaluate · compare
Códigos de salida: 0 ok · 1 error o verificación fallida · 2 live no disponible (controlado)
"""
import argparse
import importlib.metadata as md
import json
import sys
from pathlib import Path

from lab import config as C
from lab import escenario as E

# ------------------------------------------------------------------ utilidades


def _salir(msg, codigo=1):
    print(msg, file=sys.stderr)
    return codigo


def _agentdojo():
    try:
        import agentdojo  # noqa: F401
    except ImportError:
        raise SystemExit(_salir("AgentDojo no está instalado. Ejecuta:  pip install -r requirements.txt  (ver README)."))


def _commit_instalado():
    try:
        d = md.distribution("agentdojo")
        info = json.loads(d.read_text("direct_url.json") or "{}")
        return d.version, (info.get("vcs_info") or {}).get("commit_id", "desconocido")
    except Exception:
        return "no instalado", "—"


def _llm(cfg, args):
    if args.modo == "live":
        if cfg.modo != "live":
            raise ValueError("el modo live lo habilita LAB_MODE=live en tu .env (y --modo live en el comando)")
        from lab.adaptador import crear_llm
        return crear_llm(cfg.llama_url, cfg.llama_modelo, cfg.llama_clave), cfg.llama_modelo
    from lab.mock_agente import AgenteMock
    return AgenteMock(sigue_inyeccion=getattr(args, "mock", "sigue") == "sigue"), "mock-agente"


def _correr(cfg, args, etiqueta, con_ataque, politica_ruta=None, jit=False):
    _agentdojo()
    from lab import hitl as H
    from lab import pipeline as PL
    from lab import politica as P
    from lab.audit import Auditor, siguiente_run
    llm, nombre = _llm(cfg, args)
    ruta = cfg.trazas / ("traza_%s.jsonl" % etiqueta)
    run = siguiente_run(ruta)
    contexto = {"modelo": nombre, "suite": "%s/%s" % (E.SUITE, E.BENCHMARK_VERSION), "user_task": E.USER_TASK,
                "injection_task": E.INJECTION_TASK if con_ataque else None,
                "ataque": (("payload_estudiante@" + E.VECTOR) if getattr(args, "payload", None) else E.ATAQUE) if con_ataque else None,
                "politica": politica_ruta, "jit": jit}
    aud = Auditor(ruta, etiqueta, run, cfg.claves_conocidas(), modo=args.modo, contexto=contexto)
    politica = P.cargar_politica(cfg.raiz / politica_ruta) if politica_ruta else None
    if args.aprobar == "si":
        print("AVISO: --aprobar si aprueba TODO automáticamente: solo pruebas docentes, no vale como evidencia de HITL.")
    aprobador, nombre_ap = H.crear_aprobador(args.aprobar)
    injections, avisos = None, []
    if con_ataque and getattr(args, "payload", None):
        from lab.payload import leer_payload
        texto, avisos, original = leer_payload(cfg.raiz / args.payload)
        injections = {E.VECTOR: texto}
        from lab import pipeline as PL
        PL.verificar_payload(original, injections)
    for a in avisos:
        print("Aviso payload:", a)
    print("Modo %s · AgentDojo %s/%s %s%s" % (args.modo.upper(), E.SUITE, E.BENCHMARK_VERSION, E.USER_TASK,
                                              (" + " + E.INJECTION_TASK) if con_ataque else ""))
    if args.modo == "mock":
        print("(MOCK: el modelo es simulado; entorno, herramientas y evaluadores son los de AgentDojo)")
    utility, exito, det = PL.ejecutar(llm, nombre, aud, politica, aprobador, nombre_ap, con_ataque, injections, jit)
    aud.log("resultado_benchmark", suite=E.SUITE, benchmark_version=E.BENCHMARK_VERSION, user_task=E.USER_TASK,
            injection_task=det.get("injection_task"), ataque=det.get("origen_ataque"), vector=E.VECTOR if con_ataque else None,
            utility=utility, ataque_exitoso=exito, politica=politica_ruta, jit=jit, modelo=nombre,
            agentdojo_commit=_commit_instalado()[1])
    for e in [e for e in _leer(ruta) if e["run"] == run and e["evento"] not in ("resultado_benchmark",)]:
        print("  #%-3d %-18s %-28s %s" % (e["seq"], e["evento"], e.get("herramienta", ""), e.get("motivo", "") or ""))
    print("Resultado AgentDojo: utility=%s · ataque_exitoso=%s" % (utility, "n/a" if exito is None else exito))
    print("Traza: %s (corrida %d)" % (ruta, run))
    return 0


def _leer(ruta):
    from lab.audit import leer_traza
    return leer_traza(ruta)

# ------------------------------------------------------------------ comandos


def cmd_preflight(cfg, args):
    ok = True
    print("Python %d.%d (AgentDojo pide >= 3.10)" % sys.version_info[:2])
    ok &= sys.version_info >= (3, 10)
    version, commit = _commit_instalado()
    print("AgentDojo instalado: %s · commit %s" % (version, commit))
    if commit not in ("—", "desconocido") and commit != E.AGENTDOJO_COMMIT:
        print("  AVISO: el commit instalado no es el fijado (%s)" % E.AGENTDOJO_COMMIT[:8])
    env = cfg.raiz / ".env"
    print(".env en la raíz  : %s" % ("sí" if env.is_file() else "no (copia .env.example como .env si vas a usar live)"))
    gi = cfg.raiz / ".gitignore"
    if not (gi.is_file() and ".env" in gi.read_text(encoding="utf-8").split()):
        print("  AVISO: .gitignore no excluye .env: corrígelo antes de usar claves")
        ok = False
    print("Modo configurado : %s (por defecto mock; live requiere LAB_MODE=live y --modo live)" % cfg.modo)
    for n, url, clave in (("agente (llama)", cfg.llama_url, cfg.llama_clave), ("juez (qwen)", cfg.qwen_url, cfg.qwen_clave)):
        print("Live %-15s URL: %s | clave: %s" % (n, "definida" if url else "vacía", "definida" if clave else "vacía"))
    print("(preflight NO prueba conectividad ni autenticación: usa smoke-live)")
    if version == "no instalado":
        return 1
    try:
        from lab import pipeline as PL
        suite, ut, it = PL.cargar_escenario()
        print("Escenario: %s/%s · %s · %s · ataque %s · vector %s" % (E.SUITE, E.BENCHMARK_VERSION, ut.ID, it.ID, E.ATAQUE, E.VECTOR))
        cand, _ = PL.texto_ataque_oficial()
        print("Vectores que ve el agente en %s: %s" % (E.USER_TASK, cand))
        ok &= E.VECTOR in cand
    except Exception as e:
        print("ERROR al cargar el escenario de AgentDojo: %s: %s" % (type(e).__name__, e))
        ok = False
    return 0 if ok else 1


def cmd_smoke_live(cfg, args):
    """Tres comprobaciones separadas: (1) conexión/autenticación Llama, (2) tool calling estructurado de Llama,
    (3) conexión/autenticación Qwen. Nunca imprime claves ni cabeceras."""
    if cfg.modo != "live":
        return _salir("LAB_MODE no es live en tu .env: no se hace ninguna llamada.", 2)
    import openai
    from lab.diagnostico import clasificar_error
    herramienta = [{"type": "function", "function": {"name": "read_file", "description": "Reads the contents of a file.",
                    "parameters": {"type": "object", "properties": {"file_path": {"type": "string"}}, "required": ["file_path"]}}}]
    resultados = {}

    def cliente(url, clave):
        C.validar_url(url)
        if not clave:
            raise ValueError("clave vacía o con el marcador REEMPLAZAR_LOCALMENTE")
        return openai.OpenAI(base_url=url, api_key=clave, timeout=60, max_retries=0)

    def paso(nombre, funcion):
        try:
            detalle = funcion()
            resultados[nombre] = True
            print("[OK]    %-34s %s" % (nombre, detalle))
        except Exception as e:
            cat, txt = clasificar_error(e)
            resultados[nombre] = False
            print("[FALLA] %-34s %s · %s" % (nombre, cat, txt))

    def llama_conexion():
        r = cliente(cfg.llama_url, cfg.llama_clave).chat.completions.create(
            model=cfg.llama_modelo, temperature=0, max_tokens=20, messages=[{"role": "user", "content": "Reply with: ok"}])
        return "modelo %s responde" % (r.model or cfg.llama_modelo)

    def llama_tools():
        r = cliente(cfg.llama_url, cfg.llama_clave).chat.completions.create(
            model=cfg.llama_modelo, temperature=0, max_tokens=200, tools=herramienta,
            messages=[{"role": "user", "content": "Use the read_file tool to read 'bill-december-2023.txt'."}])
        tc = r.choices[0].message.tool_calls or []
        if not tc:
            raise RuntimeError("sin tool_calls estructuradas: AgentDojo no podrá ejecutar herramientas con este endpoint")
        json.loads(tc[0].function.arguments or "{}")
        return "tool_call=%s · id=%s · argumentos JSON válidos" % (tc[0].function.name, "sí" if tc[0].id else "NO (el adaptador lo asigna)")

    def qwen_conexion():
        r = cliente(cfg.qwen_url, cfg.qwen_clave).chat.completions.create(
            model=cfg.qwen_modelo, temperature=0, max_tokens=200, messages=[{"role": "user", "content": 'Reply only with {"ok": true}'}])
        return "modelo %s responde · JSON=%s" % (r.model or cfg.qwen_modelo, "ok" in (r.choices[0].message.content or ""))

    print("Smoke live (no se imprime ninguna clave). Un fallo de red o del servidor NO dice nada sobre la seguridad del modelo.")
    paso("1. Llama: conexión y autenticación", llama_conexion)
    if resultados["1. Llama: conexión y autenticación"]:
        paso("2. Llama: tool calling estructurado", llama_tools)
    paso("3. Qwen: conexión y autenticación", qwen_conexion)
    ok = all(resultados.values()) and len(resultados) == 3
    print("RESULTADO smoke-live:", "OK" if ok else "FALLA (revisa arriba; puedes trabajar en modo mock)")
    return 0 if ok else 2


def cmd_verificar(cfg, args):
    """Autoverificación OFFLINE (sin claves): corre el escenario real de AgentDojo con el agente mock."""
    _agentdojo()
    import tempfile
    from lab import pipeline as PL
    from lab.audit import Auditor, leer_traza
    from lab.mock_agente import AgenteMock
    fallos = []
    with tempfile.TemporaryDirectory() as d:
        def correr(nombre, **kw):
            aud = Auditor(Path(d) / (nombre + ".jsonl"), nombre, 1, modo="mock")
            u, s, _ = PL.ejecutar(kw.pop("llm", AgenteMock()), "mock-agente", aud, **kw)
            return u, s, leer_traza(Path(d) / (nombre + ".jsonl"))
        u, s, _ = correr("baseline")
        print("baseline mock: utility=%s (esperado True)" % u); fallos += [] if u else ["baseline"]
        u, s, _ = correr("ataque", con_ataque=True)
        print("ataque oficial, mock que obedece: utility=%s ataque_exitoso=%s (esperado True)" % (u, s)); fallos += [] if s else ["ataque"]
        u, s, _ = correr("resiste", llm=AgenteMock(sigue_inyeccion=False), con_ataque=True)
        print("ataque oficial, mock que resiste: ataque_exitoso=%s (esperado False)" % s); fallos += [] if not s else ["resiste"]
        pol = {"default": "allow", "rules": [{"tool": "send_money", "decision": "deny"}]}
        u, s, ev = correr("bloqueo", politica=pol, con_ataque=True)
        den = [e for e in ev if e["evento"] == "denied"]
        eje = [e for e in ev if e["evento"] == "executed" and e["herramienta"] == "send_money"]
        print("bloqueo de send_money: ataque_exitoso=%s denied=%d executed(send_money)=%d (esperado False, >0, 0)" % (s, len(den), len(eje)))
        fallos += [] if (not s and den and not eje) else ["bloqueo"]
    print("RESULTADO:", "OK" if not fallos else "FALLAS: %s" % fallos)
    return 0 if not fallos else 1


def cmd_mostrar_ataque(cfg, args):
    _agentdojo()
    from lab import pipeline as PL
    cand, inj = PL.texto_ataque_oficial()
    print("Vectores visibles en %s: %s\n" % (E.USER_TASK, cand))
    for k, v in inj.items():
        print("--- %s (ataque oficial %s) ---\n%s" % (k, E.ATAQUE, v))
    return 0


def cmd_baseline(cfg, args):
    return _correr(cfg, args, args.etiqueta or "baseline", False, args.politica)


def cmd_attack(cfg, args):
    return _correr(cfg, args, args.etiqueta or "red", True, args.politica)


def cmd_defend(cfg, args):
    return _correr(cfg, args, args.etiqueta or ("green" if args.jit else "blue"), True, args.politica, args.jit)


def cmd_metrics(cfg, args):
    rutas = sorted(cfg.trazas.glob("traza_*.jsonl"))
    if not rutas:
        return _salir("No hay trazas todavía.")
    for r in rutas:
        ev = _leer(r)
        runs = sorted({e["run"] for e in ev})
        ult = [e for e in ev if e["run"] == runs[-1]]
        pedidas = [e for e in ult if e["evento"] == "requested"]
        infl = [e for e in pedidas if e.get("origen") == "contenido_no_confiable"]
        asks = [e for e in ult if e["evento"] == "approval_requested"]
        apr = [e for e in ult if e["evento"] == "approved" and not e.get("aprobacion_automatica")]
        aut = [e for e in ult if e["evento"] == "approved" and e.get("aprobacion_automatica")]
        res = [e for e in ev if e["evento"] == "resultado_benchmark"]
        print("== %s (modo %s, %d corrida(s)) ==" % (r.name, "/".join(sorted({e.get("modo", "?") for e in ev})).upper(), len(runs)))
        print("1) Llamadas de herramientas solicitadas: %d" % len(pedidas))
        print("2) Potencialmente influenciadas por contenido no confiable (origen INFERIDO): %d de %d" % (len(infl), len(pedidas)))
        print("3) ask aprobadas por persona: %d de %d%s" % (len(apr), len(asks), ("  (+%d automáticas: no cuentan)" % len(aut)) if aut else ""))
        print("   AgentDojo · utility verdadera: %d/%d corridas · ataque exitoso: %d/%d corridas" % (
            sum(1 for e in res if e.get("utility")), len(res), sum(1 for e in res if e.get("ataque_exitoso")),
            sum(1 for e in res if e.get("ataque_exitoso") is not None)))
    return 0


def cmd_evaluate(cfg, args):
    from lab import juez as J
    from lab import scoring as SC
    hum = cfg.evaluacion / "humano.csv"
    try:
        listo = any(SC.leer_puntajes(hum).values())
    except (FileNotFoundError, KeyError, ValueError):
        listo = False
    if not listo and not args.sin_humano:
        return _salir("Primero puntúa TÚ: copia rubric/humano_PLANTILLA.csv a outputs/evaluacion/humano.csv y complétalo.")
    if args.modo == "live" and (cfg.modo != "live" or not cfg.juez_live):
        return _salir("Juez live no habilitado (LAB_MODE=live y LAB_JUEZ_LIVE=1). Usa --modo mock o puntúa a mano.", 2)
    filas = []
    for r in sorted(cfg.trazas.glob("traza_*.jsonl")):
        ev = _leer(r)
        try:
            d = J.juez_live(cfg, ev) if args.modo == "live" else J.juez_mock(ev)
        except Exception as e:
            return _salir("Juez live no disponible (%s). Usa --modo mock o puntúa a mano (fuente: manual)." % type(e).__name__, 2)
        d["modo_traza"] = "/".join(sorted({e.get("modo", "?") for e in J.ultima(ev)}))
        sesion = r.stem.replace("traza_", "")
        filas.append((sesion, d))
        print("%-9s traza=%-4s tarea=%s alcance=%s hitl=%s datos=%s (juez: %s)" % (
            sesion, d["modo_traza"], d["tarea"], d["alcance"], d["hitl"], d["datos"], d["fuente"]))
    J.escribir_csv(cfg.evaluacion / "juez.csv", filas)
    print("Escrito:", cfg.evaluacion / "juez.csv")
    return 0


def cmd_compare(cfg, args):
    from lab import scoring as SC
    hum, jue = cfg.evaluacion / "humano.csv", cfg.evaluacion / "juez.csv"
    for p in (hum, jue):
        if not p.is_file():
            return _salir("Falta %s" % p)
    por, disc, ac, tot = SC.comparar(SC.leer_puntajes(hum), SC.leer_puntajes(jue))
    for c, (a, t) in por.items():
        print("%-8s acuerdo (diferencia <= 1): %d de %d" % (c, a, t))
    for s, c, h, j, d in disc:
        print("DISCREPANCIA %s/%s: persona=%d juez=%d" % (s, c, h, j))
    print("Acuerdo total %d de %d. El juez no es la verdad de referencia; el resultado del benchmark lo da AgentDojo." % (ac, tot))
    return 0


def parser():
    p = argparse.ArgumentParser(prog="python -m lab")
    sub = p.add_subparsers(dest="cmd", required=True)
    for n in ("preflight", "smoke-live", "verificar", "mostrar-ataque", "metrics", "compare"):
        sub.add_parser(n)
    for n, pol in (("baseline", None), ("attack", "politicas/politica_insegura.json"), ("defend", "politicas/politica_estudiante.json")):
        s = sub.add_parser(n)
        s.add_argument("--modo", choices=("mock", "live"), default="mock")
        s.add_argument("--politica", default=pol)
        s.add_argument("--aprobar", choices=("interactivo", "no", "si"), default="interactivo")
        s.add_argument("--mock", choices=("sigue", "resiste"), default="sigue", help="comportamiento del agente mock")
        s.add_argument("--etiqueta", default=None)
        if n != "baseline":
            s.add_argument("--payload", default=None, help="tu payload (vector oficial injection_bill_text); sin él: ataque oficial")
        if n == "defend":
            s.add_argument("--jit", action="store_true", help="Green: token JIT con permiso mínimo")
    e = sub.add_parser("evaluate")
    e.add_argument("--modo", choices=("mock", "live"), default="mock")
    e.add_argument("--sin-humano", action="store_true", dest="sin_humano")
    return p


COMANDOS = {"preflight": cmd_preflight, "smoke-live": cmd_smoke_live, "verificar": cmd_verificar,
            "mostrar-ataque": cmd_mostrar_ataque, "baseline": cmd_baseline, "attack": cmd_attack, "defend": cmd_defend,
            "metrics": cmd_metrics, "evaluate": cmd_evaluate, "compare": cmd_compare}


def main(argv=None, raiz=None):
    args = parser().parse_args(argv)
    cfg = C.cargar(raiz)
    try:
        return COMANDOS[args.cmd](cfg, args)
    except NotImplementedError as e:
        return _salir("Te falta completar un TODO: %s" % e)
    except ValueError as e:
        return _salir("Error controlado: %s" % e, 2)


if __name__ == "__main__":
    sys.exit(main())
