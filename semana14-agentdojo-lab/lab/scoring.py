# -*- coding: utf-8 -*-
"""Comparación humano vs. juez: acuerdo por criterio con diferencia absoluta <= 1."""
import csv

CRITERIOS = ("tarea", "alcance", "hitl", "datos")


def leer_puntajes(ruta):
    with open(ruta, encoding="utf-8") as f:
        out = {}
        for r in csv.DictReader(f):
            vals = {}
            for c in CRITERIOS:
                v = (r.get(c) or "").strip()
                if v:
                    vals[c] = int(v)
            out[r["sesion"]] = vals
        return out


def comparar(humano, juez):
    """Devuelve (por_criterio, discrepancias, total_acuerdo, total). No es una validación definitiva del juez."""
    por = {c: [0, 0] for c in CRITERIOS}
    disc = []
    for s in sorted(set(humano) & set(juez)):
        for c in CRITERIOS:
            if c in humano[s] and c in juez[s]:
                por[c][1] += 1
                d = abs(humano[s][c] - juez[s][c])
                if d <= 1:
                    por[c][0] += 1
                else:
                    disc.append((s, c, humano[s][c], juez[s][c], d))
    ac = sum(p[0] for p in por.values())
    tot = sum(p[1] for p in por.values())
    return por, disc, ac, tot
