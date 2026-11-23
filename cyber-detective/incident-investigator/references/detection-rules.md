# Reglas de detección — incident-investigator

Estas reglas se aplican sobre un CSV con cabecera `timestamp,ip,user,event,result,detail`.
Los resultados son **alertas justificadas**, no conclusiones forenses.

---

## Regla 1. Fuerza bruta probable

**Condición de activación** (todas deben cumplirse):

- Seis o más eventos con `event = login` y `result = failed`.
- Misma `ip` y mismo `user`.
- Dentro de una ventana de cinco minutos (límites inclusivos).

**Comprobación separada de éxito posterior:**

- Indica por separado si aparece al menos un evento `login` con `result = success` de la misma `ip` y el mismo `user` dentro de los cinco minutos siguientes (límites inclusivos).
- Este dato no forma parte de la condición de activación. Se reporta como un campo aparte en la alerta, con su fila de origen.
- Convención operativa: los cinco minutos posteriores se cuentan desde el timestamp del último fallo de la ventana que activó la regla.
- Esta convención solo determina cómo se comprueba y reporta el éxito posterior. **No modifica el umbral de fuerza bruta** (seis o más fallos en cinco minutos), que se evalúa de forma independiente.
- Si el archivo termina antes de que se completen los cinco minutos, declara que no hay datos suficientes para evaluarlo.

**Severidad orientativa:**

- `alta`: la regla se activa y aparece el `login/success` posterior.
- `media`: la regla se activa sin `login/success` posterior dentro del periodo analizado.

---

## Regla 2. Password spraying probable

**Condición de activación** (todas deben cumplirse):

- Una misma `ip` genera al menos cinco eventos exactos `login/failed` (`event = login` y `result = failed`).
- Esos eventos involucran al menos cinco `user` diferentes.
- Todo ocurre dentro de una ventana de cinco minutos (límites inclusivos).

**Severidad orientativa:**

- `media`: siempre que se cumpla la condición anterior.

---

## Regla 3. Posible token expuesto

**Condición de activación:**

- El campo `detail` contiene la subcadena `token=` (distinción de mayúsculas y minúsculas tal cual, sin normalizar).

**Tratamiento obligatorio del dato:**

- **Nunca** mostrar el valor completo del token.
- Sustituir el valor por `[REDACTED]` en cualquier salida: tablas, citas y resúmenes. Se muestra la clave y el resto del texto de `detail` solo si no revela el valor.
- Ejemplo de presentación: `token=[REDACTED]`.

**Severidad orientativa:**

- `alta`: siempre que se active la regla, por tratarse de un posible secreto expuesto.

---

## Regla 4. Escalamiento no autorizado según el registro

**Condición de activación:**

- Evento `role_change` con `result = success` **y** `approved=false` presente en el campo `detail`.

**Restricciones de interpretación:**

- Se trata de una alerta basada en lo que el registro indica. No se infiere culpabilidad.
- No se afirma que una persona realizó intencionalmente una acción maliciosa. Se describe la cuenta (`user`) asociada al evento y la ausencia de aprobación registrada.
- Se busca `approved=false` únicamente dentro del campo `detail`.
- Si el campo `approved` no aparece en `detail`, la regla **no se activa** y no se infiere su valor a partir de otros campos ni del contexto de la fila.

**Severidad orientativa:**

- `alta`: la regla se activa.

---

## Regla 5. Falsos positivos

Estas situaciones **no** deben generar alerta por sí mismas:

- **Tres fallos aislados** de `login/failed` (misma IP y usuario, o misma IP con pocos usuarios) **no cumplen** el umbral de la Regla 1 (seis o más) ni el de la Regla 2 (cinco o más usuarios distintos). Pueden mencionarse como actividad normal o de baja relevancia, nunca como fuerza bruta.
- Un evento `healthcheck` **no equivale** a `login/failed`, aunque su `result` sea de fallo. No se cuenta en ninguna regla de autenticación.
- Coincidencias de texto que no encajen en la condición exacta de una regla (p. ej., `approved=true`, o `token` sin el signo `=`) no activan esa regla.

---

## Regla 6. Convenciones de análisis

Aplican a todas las reglas anteriores:

1. **Ordenar cronológicamente** las filas por `timestamp` antes de calcular cualquier ventana de tiempo.
2. **Límites inclusivos**: una ventana de cinco minutos incluye los eventos exactamente en el inicio y en el final (por ejemplo, de 10:00:00 a 10:05:00 inclusive).
3. **Coincidencia exacta** de `event` y `result`: solo se cuentan las combinaciones `login` + `failed`, `login` + `success` y `role_change` + `success`. No se usan coincidencias parciales ni sinónimos.
4. **Citar filas originales**: cada evidencia referencia su número de fila en el CSV, contando la cabecera como fila 1.
5. **Duplicados**: si existen filas duplicadas que no puedan identificarse con fiabilidad (por ejemplo, sin una clave que las distinga), declara la limitación en la salida. No elimines ni inventes reglas para tratarlas.
6. **Naturaleza de los hallazgos**: cada resultado es una alerta justificada por una o más filas. No es una conclusión forense ni prueba de un incidente.
