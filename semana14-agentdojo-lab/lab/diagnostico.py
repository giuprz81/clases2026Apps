# -*- coding: utf-8 -*-
"""Diagnóstico de errores de los endpoints (sin dependencias). Explica la causa probable SIN mostrar claves ni cabeceras.

Un fallo de red, del servidor o de saturación NO dice nada sobre si el LLM es vulnerable o resistente.
"""


def _cadena(e):
    vistos, x = [], e
    while x is not None and len(vistos) < 6:
        vistos.append(x)
        x = x.__cause__ or x.__context__
    return vistos


def clasificar_error(e):
    """Devuelve (categoria, explicacion) a partir de una excepción del cliente OpenAI-compatible o de la red."""
    codigo = getattr(e, "status_code", None)
    if codigo in (401, 403):
        return "autenticacion", "HTTP %d: clave rechazada o sin permiso (revisa la clave en .env y el esquema Bearer del gateway)" % codigo
    if codigo == 404:
        return "ruta_o_modelo", "HTTP 404: revisa la URL (/llama/v1 o /qwen/v1) y el nombre exacto del modelo"
    if codigo == 429:
        return "saturacion", "HTTP 429: demasiadas solicitudes o cuota agotada; espera o usa modo mock"
    if codigo is not None and codigo >= 500:
        return "servidor", "HTTP %d: error del servidor o de su acceso público (puede estar caído o saturado)" % codigo
    if codigo == 400:
        return "formato", "HTTP 400: el endpoint rechazó el formato de la solicitud (rol, herramientas o contenido)"
    nombres = " ".join(type(x).__name__ for x in _cadena(e)).lower()
    texto = " ".join(str(x) for x in _cadena(e)).lower()
    if "timeout" in nombres or "timed out" in texto:
        return "timeout", "tiempo agotado: el servidor o la GPU no responden a tiempo (carga alta o servidor caído)"
    if "ssl" in nombres or "certificate" in texto:
        return "ssl", "error SSL/TLS: certificado o proxy intermedio; revisa la URL https"
    if "gaierror" in nombres or "name or service not known" in texto or "getaddrinfo" in texto or "nodename" in texto:
        return "dns", "DNS: el dominio no resuelve (revisa la URL o si el servidor del docente está en línea)"
    if "connect" in nombres or "connection" in texto:
        return "conexion", "no se pudo conectar: servidor apagado, firewall o URL incorrecta"
    if isinstance(e, ValueError):
        return "configuracion", str(e)
    return "desconocido", type(e).__name__
