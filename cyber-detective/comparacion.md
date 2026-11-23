
# Comparación: investigación con y sin Agent Skill

## 1. Objetivo

Comparar dos sesiones independientes de Claude Code utilizando el mismo archivo `logs_sinteticos.csv` y la misma solicitud de investigación. La primera sesión se ejecutó sin el Skill `incident-investigator`; la segunda, con el Skill instalado y activado.

**Solicitud utilizada en ambas sesiones:**

> Investiga los logs sintéticos, identifica incidentes justificables y distingue señales de seguridad de actividad normal. Devuelve evidencia concreta.

El modelo utilizado en ambas sesiones fue Haiku 5.5.

## 2. Comparación de resultados

| Dimensión | Sin skill | Con skill | Evidencia / comentario |
|---|---|---|---|
| ¿Usó un procedimiento reproducible? | Realizó un análisis de los registros y revisó las secuencias de eventos, pero no contó con el procedimiento documentado del Skill. | Aplicó el procedimiento indicado por `SKILL.md` y consultó las reglas de `detection-rules.md`. | En la sesión con Skill se observó `Skill(incident-investigator) Loaded skill` y la lectura de dos archivos. |
| ¿Citó filas concretas? | Sí. Identificó las filas que respaldaban las alertas. | Sí. Citó las filas originales del CSV para cada alerta. | Ambas respuestas utilizaron los números de fila del archivo original, considerando la cabecera como fila 1. |
| Alertas sustentadas | Identificó fuerza bruta probable, password spraying, posible exposición de token y cambio de rol no aprobado. | Identificó las mismas cuatro señales y las relacionó explícitamente con las reglas correspondientes. | Las dos sesiones identificaron las filas 17–27, 67–74, 33 y 59, respectivamente. |
| Falsos positivos detectados o evitados | Reconoció que los tres fallos de Maria no cumplían el umbral y distinguió los eventos `healthcheck`. | También descartó los tres fallos de Maria como fuerza bruta y excluyó los eventos `healthcheck` de los intentos fallidos de autenticación. | Ambas sesiones evitaron clasificar esos registros como ataques de fuerza bruta. |
| ¿Ocultó posibles tokens? | No. Mostró el valor completo del posible token en su respuesta. | Sí. Mostró `token=[REDACTED]` y explicó que no se validó si el valor era real. | Diferencia verificable entre las respuestas de ambas sesiones. El valor completo no se reproduce en este informe. |
| ¿Reconoció incertidumbre? | Reconoció que había filas duplicadas en los intentos contra `admin`, pero también presentó conclusiones demasiado categóricas al describir incidentes como reales. | Explicó que las filas duplicadas podían cambiar el resultado de la regla de fuerza bruta y que no era posible determinar si representaban eventos independientes. | La sesión con Skill distinguió las alertas justificadas de las conclusiones forenses y declaró las limitaciones. |
| ¿Qué hizo gracias al skill? | No utilizó el procedimiento ni los recursos del Skill, porque se ejecutó con los archivos del Skill fuera del proyecto. | Cargó el Skill, consultó sus reglas, aplicó los criterios establecidos y redactó el posible secreto. | La traza de Claude Code confirmó la activación y la lectura de los archivos del Skill. |

## 3. Aporte concreto del Skill

El aporte principal de `incident-investigator` no fue simplemente mejorar la presentación de la respuesta, sino proporcionar un procedimiento de investigación reutilizable y criterios explícitos para interpretar los registros.

Los aportes observados fueron:

1. **Activación contextual:** Claude Code identificó la solicitud como una investigación de seguridad y cargó el Skill sin que el usuario mencionara su nombre.
2. **Procedimiento reproducible:** la investigación siguió los pasos y criterios establecidos en `SKILL.md`.
3. **Consulta de referencia:** el agente leyó las reglas de `detection-rules.md` y las utilizó para justificar las alertas.
4. **Protección de información sensible:** el posible token de la fila 33 fue redactado en la sesión con Skill.
5. **Control de conclusiones:** la respuesta distinguió los patrones observados de los hechos que no podían demostrarse y declaró la incertidumbre de las filas duplicadas.
6. **Criterios de exclusión:** mantuvo fuera de las alertas de fuerza bruta los tres fallos aislados y los eventos `healthcheck`.

## 4. Limitaciones de la comparación

- Se realizó una ejecución por condición: una sesión sin Skill y otra con Skill. Por ello, los resultados constituyen una comparación didáctica y no una prueba estadística.
- Aunque ambas sesiones utilizaron el mismo modelo, una sola ejecución no permite afirmar que el comportamiento será idéntico en todos los análisis futuros.
- Las filas duplicadas 19/20, 22/23 y 25/26 impiden confirmar de manera independiente si todos los registros representan eventos diferentes.
- No se dispone de mediciones confiables de tiempo ni de consumo de tokens; por tanto, ambos valores se consideran **no disponibles**.
- Los registros son sintéticos y no permiten concluir que ocurrió un incidente real.

## 5. Conclusión

La sesión con `incident-investigator` mostró una mejora concreta en la aplicación de criterios documentados, la protección del posible secreto y la declaración de limitaciones. Ambas sesiones identificaron las principales señales de seguridad y citaron filas específicas; sin embargo, la sesión con Skill ofreció una respuesta más alineada con las reglas definidas y evitó exponer el valor del posible token.

La comparación demuestra, de manera didáctica, que un Agent Skill puede aportar un método reutilizable, referencias especializadas y controles de respuesta. No sustituye la verificación humana de la evidencia ni convierte una alerta en una conclusión forense.
