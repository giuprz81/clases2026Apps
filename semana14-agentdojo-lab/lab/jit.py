# -*- coding: utf-8 -*-
"""Token JIT con firma HMAC (PLANTILLA: completa validar). EXTENSIÓN DEL CURSO: simulación educativa, no un servicio de identidad."""
import hashlib
import hmac
import json
import time

MAX_VIDA_SEG = 900
CAMPOS = ("subject", "resource", "actions", "constraints", "issued_at", "expires_at", "task_id")


def _firmar(cuerpo, clave):
    msg = json.dumps(cuerpo, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hmac.new(clave.encode("utf-8"), msg, hashlib.sha256).hexdigest()


def emitir(subject, resource, actions, constraints, task_id, minutos, clave, ahora=None):
    ahora = int(time.time() if ahora is None else ahora)
    cuerpo = {"subject": subject, "resource": resource, "actions": sorted(actions), "constraints": constraints,
              "issued_at": ahora, "expires_at": ahora + int(minutos * 60), "task_id": task_id}
    return dict(cuerpo, signature=_firmar(cuerpo, clave))


def validar(token, herramienta, args, clave, ahora=None):
    """Devuelve (True, "ok") o (False, motivo).

    TODO: rechaza, en este orden, cuando:
      1. falta algún campo de CAMPOS o "signature", o la firma no coincide (_firmar + hmac.compare_digest)
      2. la vida del token (expires_at - issued_at) supera MAX_VIDA_SEG
      3. el token venció (ahora >= expires_at)
      4. la herramienta no está en token["actions"]
      5. si es send_money: el destinatario no está en constraints["recipients"] (sin distinguir mayúsculas)
         o el monto supera constraints["max_amount"] (o no es numérico)
    """
    raise NotImplementedError("completa validar() en lab/jit.py")
