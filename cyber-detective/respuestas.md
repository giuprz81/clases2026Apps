
# Plugin Detective — Respuestas

## 1. Skill frente a Plugin

`incident-investigator` es un **Agent Skill** porque contiene instrucciones y recursos especializados para realizar una tarea concreta: investigar archivos CSV con registros de autenticación y seguridad. Su archivo `SKILL.md` define cuándo debe activarse, qué procedimiento seguir, qué reglas consultar y cómo presentar los hallazgos. Además, `references/detection-rules.md` contiene los criterios técnicos que utiliza durante el análisis.

Un **Plugin**, en cambio, es un paquete distribuible que puede integrar varias extensiones y capacidades. Para distribuir `incident-investigator` como un plugin se podrían incorporar:

- **Skill:** conservar las instrucciones y las reglas de investigación.
- **Comando:** permitir iniciar una investigación mediante una instrucción específica, por ejemplo `/investigate-logs`.
- **Hook:** automatizar comprobaciones ante determinados eventos, como revisar que los informes no contengan posibles secretos antes de finalizar.
- **MCP:** proporcionar acceso estandarizado a herramientas o recursos externos autorizados, si fueran necesarios.
- **Manifiesto:** declarar la identidad del plugin, sus componentes, versiones y configuración de instalación, de acuerdo con el formato de la plataforma.

En conclusión, el Skill proporciona el conocimiento y el procedimiento; el Plugin puede reunirlo con comandos, hooks y otras capacidades para facilitar su distribución e integración. No son equivalentes ni un Skill necesita obligatoriamente convertirse en Plugin.

## 2. Ralph Loop

Ralph Loop podría utilizarse para repetir la investigación y corregir errores detectados mediante comprobaciones verificables. En este proyecto se podría establecer un máximo de **3 iteraciones**, manteniendo el mismo CSV original y sin generar eventos ni evidencias nuevas.

El proceso sería:

1. **Primera iteración — Análisis inicial:** investigar el CSV, aplicar las reglas y generar los hallazgos con sus filas de evidencia.
2. **Segunda iteración — Verificación:** comprobar los umbrales, las ventanas de tiempo, los números de fila, los eventos excluidos y la redacción de posibles tokens. Corregir únicamente los errores demostrados por estas verificaciones.
3. **Tercera iteración — Revisión final:** volver a comprobar los hallazgos corregidos, verificar que el CSV original no haya cambiado y confirmar que las limitaciones estén declaradas.

**Criterio de parada:** detener el ciclo cuando todas las comprobaciones verificables se cumplan: las alertas respetan las reglas, las filas citadas existen en el CSV original, los posibles tokens están redactados, no se inventaron eventos y las incertidumbres están documentadas. Si no se cumplen después de la tercera iteración, detenerse igualmente e informar qué problemas siguen pendientes.

La frase de finalización de un ciclo automatizado no demuestra que el análisis sea correcto. Por eso, cada iteración debe depender de verificaciones reales y no de la afirmación del agente de que terminó satisfactoriamente.
