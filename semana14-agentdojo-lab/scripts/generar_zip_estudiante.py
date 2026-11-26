# -*- coding: utf-8 -*-
"""Crea el ZIP de ESTUDIANTES y lo revisa antes de cerrarlo.

Excluye: teacher_only/, outputs/ (solo deja carpetas vacías), runs/, .env, cachés.
Falla (sin dejar ZIP) si encuentra: claves con valor (distintas de REEMPLAZAR_LOCALMENTE), cabeceras Bearer o material de solución docente.
Uso:  python scripts/generar_zip_estudiante.py [salida.zip]
"""
import re
import sys
import zipfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
EXCLUIR = {"teacher_only", "outputs", "runs", "__pycache__", ".pytest_cache", ".venv", ".git"}
# patrones armados por partes para que este archivo no se detecte a sí mismo
PATRONES = [
    (re.compile(r"^[A-Z_]*API_KEY[ \t]*=[ \t]*(?!REEMPLAZAR_LOCALMENTE\s*$)[^ \t\r\n]+", re.M), "clave con valor"),
    (re.compile("Bear" + r"er\s+[A-Za-z0-9._-]{12,}"), "cabecera Authorization"),
    (re.compile("SOLUCI" + "ÓN DOCENTE"), "solución docente"),
]
SOLO_FUERA_DE_TESTS = [(re.compile(r"\bsk" + r"-[A-Za-z0-9]{12,}"), "clave tipo sk-")]


def archivos():
    for p in sorted(RAIZ.rglob("*")):
        rel = p.relative_to(RAIZ)
        if p.is_dir() or EXCLUIR & set(rel.parts) or p.name == ".env" or p.suffix == ".pyc":
            continue
        yield p, rel


def revisar():
    problemas = []
    for p, rel in archivos():
        if p.name == Path(__file__).name:
            continue
        try:
            txt = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        pats = PATRONES + ([] if rel.parts[0] == "tests" else SOLO_FUERA_DE_TESTS)
        for rx, motivo in pats:
            if rx.search(txt):
                problemas.append("%s: %s" % (rel, motivo))
    return problemas


def main():
    salida = Path(sys.argv[1]) if len(sys.argv) > 1 else RAIZ.parent / (RAIZ.name + ".zip")
    problemas = revisar()
    if problemas:
        print("NO se generó el ZIP. Revisa:\n  " + "\n  ".join(problemas))
        return 1
    with zipfile.ZipFile(salida, "w", zipfile.ZIP_DEFLATED) as z:
        for p, rel in archivos():
            z.write(p, Path(RAIZ.name) / rel)
        for d in ("trazas", "evaluacion"):
            z.writestr("%s/outputs/%s/.gitkeep" % (RAIZ.name, d), "")
    print("ZIP de estudiantes revisado y creado:", salida)
    return 0


if __name__ == "__main__":
    sys.exit(main())
