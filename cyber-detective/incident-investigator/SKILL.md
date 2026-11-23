---
name: incident-investigator
description: >-
  Investiga incidentes de seguridad en registros de eventos tabulares (CSV) de autenticación y cambios de privilegios.
  Trabaja con archivos locales y registros sintéticos compatibles con las columnas timestamp, ip, user, event, result y detail;
  aplica las reglas de detection-rules.md (fuerza bruta, password spraying, tokens expuestos en detail, escalamiento no aprobado)
  y presenta alertas justificadas con citas a las filas originales.
  Actívalo cuando el usuario pida investigar, revisar, correlacionar o buscar indicadores de compromiso, intentos de acceso sospechosos,
  secretos expuestos o cambios de privilegios en un CSV de logs.
  Señales positivas: "investiga", "analiza incidentes", "posible fuerza bruta", "password spraying", "token expuesto",
  "role_change", "escalamiento", "alertas de seguridad", "revisa los logs de autenticación".
  NO actives este Skill para conteos descriptivos, estadísticas generales, gráficos o visualizaciones sin una investigación de incidentes;
  tampoco para redactar código ajeno a la investigación, para consultar IPs en servicios externos ni para analizar redes en vivo.
---

# incident-investigator

Skill para investigar incidentes en registros de eventos CSV de forma reproducible. Produce **alertas justificadas**, no conclusiones forenses.

## Alcance y restricciones de seguridad

- Trabaja **exclusivamente** con archivos locales y registros sintéticos proporcionados por el usuario.
- **No** realiza conexiones de red, ni consultas externas de IP (reputación, geolocalización, WHOIS, etc.).
- **No** modifica los CSV originales. Cualquier cálculo se hace en lectura.
- **No** inventa eventos, filas, timestamps ni evidencias. Si un dato no está en el archivo, se declara como ausente.
- **Nunca** muestra un token completo: cualquier valor sensible se sustituye por `[REDACTED]`.
- **No atribuye culpabilidad** a personas. Un registro indica una acción asociada a una cuenta, no la intención de quien la usó.
- Diferencia explícitamente **actividad normal** de **actividad sospechosa**; la mayoría de filas suele ser normal.
- **No memoriza** resultados de un archivo concreto. Cada investigación se recalcula desde el CSV que se entregue, y el Skill debe funcionar con cualquier CSV con el mismo esquema.

## Formato esperado del CSV

Esquema compatible con cabecera en la fila 1:

| columna     | significado                                                |
|-------------|------------------------------------------------------------|
| `timestamp` | Marca temporal del evento                                  |
| `ip`        | Dirección de origen registrada                             |
| `user`      | Cuenta asociada al evento                                  |
| `event`     | Tipo de evento (p. ej. `login`, `role_change`, `healthcheck`) |
| `result`    | Resultado (p. ej. `success`, `failed`)                     |
| `detail`    | Texto libre con información adicional                      |

## Procedimiento de investigación

Sigue estos pasos en orden.

1. **Inspeccionar el CSV.** Verifica la cabecera, el número de columnas, el formato de `timestamp` y la codificación. Si falta alguna columna del esquema o el formato es ambiguo, detente y declara la limitación antes de continuar.
2. **Consultar `references/detection-rules.md`.** Es obligatorio cuando la investigación trate de autenticación, posibles secretos expuestos o cambios de privilegios. Aplica sus umbrales y convenciones tal cual están escritos, sin modificarlos.
3. **Analizar evidencias y ventanas temporales.** Ordena cronológicamente las filas antes de calcular cualquier ventana de tiempo. Cuenta solo combinaciones exactas de `event` y `result`. Registra la fila de origen de cada evento considerado.
4. **Diferenciar alertas de hechos confirmados.**
   - *Hecho confirmado*: una fila que, por sí sola, contiene lo que se afirma (p. ej., un `role_change/success` con `approved=false` escrito en `detail`).
   - *Alerta*: un patrón que cumple una regla por correlación de varias filas (p. ej., seis fallos en cinco minutos). Una alerta indica que hay que revisar, no que algo ocurrió con certeza.
5. **Presentar hallazgos citando filas originales.** Cita cada evidencia con su número de fila, contando la cabecera como fila 1. Usa el formato estandarizado de la sección siguiente.
6. **Declarar incertidumbres y limitaciones.** Indica duplicados no identificables con fiabilidad, ausencia de datos (p. ej., un campo que no existe en el esquema), ventanas que caen en el borde del archivo y cualquier supuesto que hayas tenido que hacer.

## Formato estandarizado de resultados

Presenta los hallazgos en una tabla con estas columnas, en este orden:

| alerta | severidad orientativa | regla | timestamp | ip | usuario | filas/evidencia | limitaciones |
|--------|-----------------------|-------|-----------|----|---------|-----------------|--------------|

- **alerta**: nombre corto del patrón detectado.
- **severidad orientativa**: `alta`, `media` o `baja`, según la escala de `detection-rules.md`.
- **regla**: identificador de la regla aplicada (p. ej., `Regla 1`).
- **timestamp**: inicio y fin de la ventana, o el instante del evento.
- **ip** y **usuario**: valores exactos del CSV.
- **filas/evidencia**: números de fila originales (cabecera = fila 1). Para `detail`, muestra el valor con `[REDACTED]` si contiene secretos.
- **limitaciones**: qué no se puede afirmar con los datos disponibles.

Si no hay alertas, presenta la tabla vacía con una fila indicando "sin alertas según las reglas aplicadas" y lista igualmente las limitaciones.

Después de la tabla, incluye una sección breve de **hechos confirmados** y otra de **actividad normal observada**, para que la lectura no quede solo con lo sospechoso.
