# Hallazgos — investigación de `logs_sinteticos.csv`

**Skill:** incident-investigator (reglas de `references/detection-rules.md`)
**Archivo:** `logs_sinteticos.csv` (solo lectura; no modificado)
**Alcance:** 93 filas de datos (filas 2–94), cabecera en fila 1 con el esquema `timestamp,ip,user,event,result,detail`. Timestamps en `-05:00`, orden cronológico verificado.

> Las alertas son **indicios justificados por filas concretas**, no conclusiones forenses ni prueba de un incidente.

---

## 1. Alertas justificadas

| alerta | severidad orientativa | regla | timestamp | ip | usuario | filas/evidencia | limitaciones |
|--------|-----------------------|-------|-----------|----|---------|-----------------|--------------|
| Fuerza bruta probable contra la cuenta `admin` con éxito posterior | alta | Regla 1 | 01:14:00 a 01:18:00 (-05:00); éxito posterior 01:19:00 | 198.51.100.77 | admin | Fallos: filas 17, 19, 20, 22, 23, 25, 26, 27 (8 eventos `login/failed`, detail `incorrect password`). Éxito posterior: fila 28 (`login/success`, detail `login after multiple failures`), dentro de 5 min desde el último fallo (fila 27, 01:18:00). | Seis de los ocho fallos forman tres pares de filas **idénticas** (19/20, 22/23 y 25/26; ver sección 4). Si cada par se contara como un solo evento, quedarían 5 fallos y el umbral de 6 **no** se cumpliría. Según la Regla 6.5 no se eliminaron. El éxito posterior indica que la cuenta autenticó, no quién lo hizo. |
| Password spraying probable desde una IP | media | Regla 2 | 02:01:00 a 02:03:00 (-05:00) | 203.0.113.89 | ana, carlos, luisa, diego, maria, sofia (6 usuarios) | Filas 67 (ana), 68 (carlos), 70 (luisa), 71 (diego), 73 (maria), 74 (sofia); todas `login/failed`, detail `incorrect password`. | Cada usuario recibe un solo fallo desde esa IP, por lo que la Regla 1 no aplica (exige misma IP y mismo usuario). No hay ningún `login/success` desde 203.0.113.89 en el archivo. Se desconoce si las cuentas existen o si la IP es de origen legítimo. |
| Posible token expuesto en `detail` | alta | Regla 3 | 01:27:00 (-05:00) | 192.0.2.44 | api_service | Fila 33 (`event=debug`, `result=warning`), detail: `token=[REDACTED]; debug output`. | El valor del token está presente en el registro, por lo que se trata como secreto expuesto aunque el texto sugiera que es de demostración. No se puede confirmar su validez ni si es real. Valor no mostrado en este informe. |
| Escalamiento no autorizado según el registro | alta | Regla 4 | 01:50:00 (-05:00) | 203.0.113.42 | guest | Fila 59 (`role_change`, `success`, detail `role=user->admin; approved=false`). | Alerta basada solo en lo que el registro indica. No se atribuye intención a ninguna persona. Se desconoce si existe una aprobación fuera de este registro. |

---

## 2. Hechos confirmados (lo que dice una fila por sí sola)

- **Fila 28:** `admin` inició sesión con éxito desde 198.51.100.77 a las 01:19:00, con detail `login after multiple failures`.
- **Fila 33:** el campo `detail` de `api_service` contiene la subcadena `token=` (valor omitido).
- **Fila 59:** un `role_change` con `result=success` para `guest` desde 203.0.113.42, con `approved=false` en `detail`.
- **Fila 57:** `guest` recibió `access/denied` sobre `resource=/admin` desde 203.0.113.42 a las 01:49:00, justo antes del cambio de rol de la fila 59. Este hecho es contextual; no forma parte de la condición de la Regla 4.

---

## 3. Actividad normal y falsos positivos

- **Tres fallos aislados que no alcanzan el umbral (Regla 5):**
  - 192.0.2.25 / `maria`: filas 38, 39 y 41 (`mistyped password`, 01:35–01:37), seguidos de `login/success` en la fila 42 (`legitimate user`, 01:38:00). Un solo usuario y tres fallos no activan ninguna regla.
  - 192.0.2.10, 192.0.2.11 y 192.0.2.12 tienen entre 3 y 4 fallos repartidos entre 3 usuarios distintos, sin ventana de 5 minutos que alcance el umbral de la Regla 1 (6 fallos de la misma IP y usuario) ni el de la Regla 2 (5 usuarios distintos desde la misma IP con 5 fallos).
- **`healthcheck` de `healthbot` desde 192.0.2.200 (filas 78, 80–84, 02:10–02:15):** monitoreo programado con `result=success`. No es `login/failed` y no cuenta en ninguna regla.
- **Inicios de sesión exitosos desde 192.0.2.10–13:** la mayoría de las filas (`login/success`, `ordinary login`) corresponde a usuarios internos sin patrón de fallos asociado.
- **Fila 57 (`access/denied`):** denegación de acceso a `/admin` para `guest`. Se registra como evento de control, no como alerta propia.

---

## 4. Duplicados, limitaciones y supuestos

- **Duplicados exactos sin clave distintiva:**
  - Filas 19 y 20 (`admin`, 01:15:00, `incorrect password`).
  - Filas 22 y 23 (`admin`, 01:16:00, `incorrect password`).
  - Filas 25 y 26 (`admin`, 01:17:00, `incorrect password`).
  - Según la Regla 6.5 no se eliminaron. La alerta de la Regla 1 depende de contarlos: sin ellos, el umbral de 6 no se alcanza. Es la limitación más relevante de la investigación.
- **Falta de campos de identificación:** el esquema no incluye un identificador de sesión ni de evento, así que no es posible distinguir reintentos reales de registros repetidos.
- **Ventana de éxito posterior:** la Regla 1 se evalúa con los 5 minutos desde el último fallo (fila 27, 01:18:00). La fila 28 (01:19:00) cae dentro de esa ventana, por lo que la comprobación queda resuelta dentro del archivo.
- **Sin datos fuera del archivo:** no se hicieron consultas de red, reputación de IP ni verificación de cuentas. Tampoco hay información sobre qué cuentas o IP son legítimas en el entorno de origen.
- **Supuestos:**
  - La numeración de filas cuenta la cabecera como fila 1.
  - Se interpreta que `detail=ordinary login` y `legitimate user` no implican por sí mismos autorización ni ilegitimidad más allá de lo que indique cada regla.
  - Se asume que `api_service` y `guest` son nombres de cuenta del propio registro, sin confirmar su uso real.
