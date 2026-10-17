# Especificación: Divisor de cuenta

**Feature Branch**: `001-dividir-cuenta`  
**Creada**: 2026-10-08  
**Estado**: Aprobada para planificación
**Entrada**: Solicitud de una aplicación Flutter offline de una sola pantalla para dividir una cuenta.

## 1. Decisiones aclaradas

- La aplicación tendrá una sola pantalla y funcionará completamente sin conexión.
- El resultado se actualizará automáticamente al cambiar cualquier entrada o el modo de redondeo.
- No existirá un botón `Calcular`.
- El separador decimal admitido será únicamente el punto (`.`). La coma decimal no estará permitida.
- El monto debe ser numérico y mayor o igual a cero.
- El porcentaje de propina debe ser numérico y estar entre 0 y 100, inclusive.
- El número de personas debe ser un entero mayor o igual a uno.
- En modo `Exacto`, el resultado se redondeará a dos decimales mediante la regla decimal de mitad hacia arriba.
- En modo `Redondeo hacia arriba`, se aplicará el techo matemático al importe individual y se mostrará con dos decimales.
- Si alguna entrada es inválida, se mostrará el mensaje correspondiente y no se presentará un importe por persona.

## 2. Alcance

La aplicación permitirá introducir el monto total de una cuenta, el número de personas y el porcentaje de propina. Calculará el total con propina y el importe correspondiente a cada persona.

La persona usuaria podrá seleccionar uno de dos modos:

- `Exacto`: presentar el importe individual redondeado a dos decimales.
- `Redondeo hacia arriba`: elevar el importe individual al siguiente entero cuando tenga una fracción y mostrarlo con dos decimales.

El cálculo será local. No se utilizarán cuentas, servicios remotos, persistencia ni conexión a Internet.

## 3. Historias de usuario y pruebas

### Historia 1 — Dividir una cuenta con resultado exacto (Prioridad: P1)

Como persona que comparte una cuenta, quiero introducir el monto, el número de personas y la propina para conocer cuánto debe pagar cada persona.

**Por qué esta prioridad:** Es el flujo principal y el valor mínimo viable de la aplicación.

**Prueba independiente:** Introducir datos válidos y comprobar que el resumen muestra el importe individual correcto con dos decimales.

**Escenarios de aceptación:**

1. **Dado** un monto de 100, 4 personas, 10 % de propina y modo `Exacto`, **cuando** se calcula, **entonces** se muestra `27.50` por persona.
2. **Dado** un monto de 90, 3 personas, 0 % de propina y modo `Exacto`, **cuando** se calcula, **entonces** se muestra `30.00` por persona.
3. **Dado** un monto de 10, 3 personas, 0 % de propina y modo `Exacto`, **cuando** se calcula, **entonces** se muestra `3.33` por persona.

### Historia 2 — Validar entradas (Prioridad: P1)

Como persona usuaria, quiero recibir mensajes claros cuando los datos no se puedan calcular para corregirlos sin ambigüedad.

**Por qué esta prioridad:** Evita resultados inválidos y permite completar el flujo principal de manera segura.

**Prueba independiente:** Introducir valores inválidos, verificar el mensaje correspondiente y comprobar que no se presenta un importe por persona.

**Escenarios de aceptación:**

1. **Dado** un monto de 50 y 0 personas, **cuando** se intenta calcular, **entonces** se muestra `Debe haber al menos una persona` y no se presenta un importe por persona.
2. **Dado** un monto vacío, formado solo por espacios o con el texto `abc`, **cuando** se intenta calcular, **entonces** se muestra `Monto invalido` y no se presenta un importe por persona.
3. **Dado** un monto negativo, **cuando** se intenta calcular, **entonces** se muestra `El monto no puede ser negativo` y no se presenta un importe por persona.
4. **Dado** un porcentaje de propina inferior a 0 o superior a 100, **cuando** se intenta calcular, **entonces** se muestra `La propina debe estar entre 0 y 100` y no se presenta un importe por persona.
5. **Dado** un porcentaje de propina vacío o no numérico, **cuando** se intenta calcular, **entonces** se muestra `Propina invalida` y no se presenta un importe por persona.
6. **Dado** un monto que utiliza coma decimal, como `12,50`, **cuando** se intenta calcular, **entonces** se muestra `Monto invalido` y no se presenta un importe por persona.
7. **Dado** un número de personas no entero, como `2.5`, **cuando** se intenta calcular, **entonces** se muestra `El número de personas debe ser un entero` y no se presenta un importe por persona.

Los valores negativos enteros del número de personas también deberán mostrar `Debe haber al menos una persona`.

### Historia 3 — Elegir el modo de redondeo (Prioridad: P2)

Como persona usuaria, quiero elegir la forma de redondear para adaptar el resultado a la forma de pago del grupo.

**Por qué esta prioridad:** Es una necesidad del producto después del cálculo exacto básico.

**Prueba independiente:** Seleccionar cada modo con los mismos datos y comprobar que el importe mostrado respeta su contrato.

**Escenarios de aceptación:**

1. **Dado** un monto de 10, 3 personas, 0 % de propina y modo `Exacto`, **cuando** se calcula, **entonces** se muestra `3.33`.
2. **Dado** un monto de 10, 3 personas, 0 % de propina y modo `Redondeo hacia arriba`, **cuando** se calcula, **entonces** se muestra `4.00`.
3. **Dado** un monto de 2.01, 2 personas, 0 % de propina y modo `Exacto`, **cuando** se calcula, **entonces** se muestra `1.01`, aplicando redondeo decimal de mitad hacia arriba.

### Historia 4 — Funcionamiento offline (Prioridad: P2)

Como persona usuaria, quiero usar el divisor sin conexión para calcular la cuenta en cualquier lugar.

**Por qué esta prioridad:** El cálculo es local y no debe depender de la disponibilidad de red.

**Prueba independiente:** Ejecutar el flujo sin acceso de red y comprobar que las entradas, el cálculo y el resultado siguen funcionando.

**Escenario de aceptación:**

1. **Dado** que el dispositivo no tiene conexión, **cuando** se introducen datos válidos y se cambia el modo de redondeo, **entonces** la aplicación calcula y actualiza el resultado sin solicitudes de red ni mensajes de conectividad.

## 4. Requisitos funcionales

- **FR-001:** La aplicación MUST presentar una única pantalla para el flujo completo.
- **FR-002:** La aplicación MUST permitir introducir un monto total de cuenta.
- **FR-003:** La aplicación MUST permitir introducir el número de personas, incluidos temporalmente valores inválidos para poder mostrar su validación.
- **FR-004:** La aplicación MUST permitir introducir un porcentaje de propina y validar que esté entre 0 y 100, inclusive.
- **FR-004a:** La aplicación MUST validar que el monto sea numérico y mayor o igual a cero.
- **FR-004b:** La aplicación MUST validar que el número de personas sea un entero mayor o igual a uno.
- **FR-004c:** La aplicación MUST aceptar únicamente el punto como separador decimal.
- **FR-005:** La aplicación MUST calcular la propina porcentual sobre el monto y sumarla para obtener el total.
- **FR-006:** La aplicación MUST calcular el importe individual dividiendo el total entre el número de personas, después de validar las entradas.
- **FR-007:** La aplicación MUST ofrecer exactamente los modos `Exacto` y `Redondeo hacia arriba`.
- **FR-008:** En modo `Exacto`, la aplicación MUST aplicar redondeo decimal de mitad hacia arriba a dos decimales y mostrar exactamente dos decimales.
- **FR-009:** En modo `Redondeo hacia arriba`, la aplicación MUST aplicar techo matemático al importe individual y mostrar el resultado con dos decimales.
- **FR-010:** Si el número de personas es cero o negativo, la aplicación MUST mostrar `Debe haber al menos una persona` y no presentar un importe por persona.
- **FR-011:** Si el monto está vacío, no es numérico o utiliza coma decimal, la aplicación MUST mostrar `Monto invalido` y no presentar un importe por persona.
- **FR-011a:** Si el monto es negativo, la aplicación MUST mostrar `El monto no puede ser negativo` y no presentar un importe por persona.
- **FR-011b:** Si el número de personas no es entero, la aplicación MUST mostrar `El número de personas debe ser un entero` y no presentar un importe por persona.
- **FR-011c:** Si la propina está vacía o no es numérica, la aplicación MUST mostrar `Propina invalida` y no presentar un importe por persona.
- **FR-011d:** Si la propina está fuera del rango permitido, la aplicación MUST mostrar `La propina debe estar entre 0 y 100` y no presentar un importe por persona.
- **FR-012:** La aplicación MUST recalcular y actualizar automáticamente el resultado cuando cambie cualquier entrada válida o el modo de redondeo. No debe requerir un botón `Calcular`.
- **FR-013:** La aplicación MUST realizar todos los cálculos localmente y no requerir red, cuenta, backend ni persistencia de datos.
- **FR-014:** Las reglas de cálculo y validación MUST estar separadas de la interfaz de usuario y ubicarse en un dominio independiente de Flutter.
- **FR-015:** La solución MUST incluir pruebas automatizadas para las reglas de dominio y los escenarios de aceptación relevantes.

## 5. Reglas de cálculo

1. La propina se calcula como `monto * porcentaje / 100`.
2. El total se calcula como `monto + propina`.
3. El importe individual se calcula como `total / personas`, después de validar que `personas >= 1` y que sea un entero.
4. El modo `Exacto` aplica redondeo decimal de mitad hacia arriba a dos decimales. Por ejemplo, `2.01 / 2 = 1.005` se presenta como `1.01`.
5. El modo `Redondeo hacia arriba` aplica techo matemático al importe individual. Por ejemplo, `3.333...` se presenta como `4.00`; un importe que ya sea entero se mantiene sin incremento y se presenta con dos decimales.
6. Todos los resultados visibles deben tener exactamente dos decimales.
7. La implementación debe evitar que los errores de representación binaria de números decimales alteren la regla monetaria de redondeo.
8. El punto es el único separador decimal permitido.
9. Una entrada vacía, no numérica o con un formato no admitido se considera inválida.
10. Si hay errores de validación, no debe mostrarse un importe individual calculado a partir de entradas inválidas.

## 6. Casos límite

- Monto vacío o formado solo por espacios: `Monto invalido`.
- Monto `abc`: `Monto invalido`.
- Monto con coma decimal, por ejemplo `12,50`: `Monto invalido`.
- Monto negativo: `El monto no puede ser negativo`.
- Número de personas igual a cero o negativo: `Debe haber al menos una persona`.
- Número de personas no entero: `El número de personas debe ser un entero`.
- Propina vacía o no numérica: `Propina invalida`.
- Propina menor que 0 o mayor que 100: `La propina debe estar entre 0 y 100`.
- Propina igual a 0: calcular sin cargo adicional.
- Propina igual a 100: aceptar y calcular normalmente.
- Resultado exacto entero: mantener dos decimales, por ejemplo `30.00`.
- Resultado exacto con fracción: aplicar redondeo decimal de mitad hacia arriba a dos decimales.
- Cambio de modo con entradas inválidas: mantener los mensajes de validación y no presentar un resultado.
- Sin conexión: el flujo no debe fallar ni intentar acceder a servicios externos.

## 7. Entidades y conceptos del dominio

- **EntradaCuenta:** monto, número de personas y porcentaje de propina introducidos por la persona usuaria.
- **EstrategiaRedondeo:** abstracción del dominio que define la operación de redondeo del importe por persona.
- **ResultadoDivision:** total calculado, importe por persona y modo de redondeo aplicado, conservando la información necesaria para presentarlo sin depender de una implementación concreta.
- **ErrorDivision:** resultado de validación con los mensajes de negocio definidos.

Las implementaciones concretas de la abstracción serán `RedondeoExacto` y `RedondeoHaciaArriba`, ubicadas en `lib/data/`. La primera aplicará redondeo decimal de mitad hacia arriba a dos decimales; la segunda aplicará techo matemático al importe por persona.

## 8. Arquitectura y restricciones

- Mantener la dirección de dependencias entre presentación y dominio, evitando que el dominio dependa de la interfaz o de las implementaciones concretas.
- Definir `EstrategiaRedondeo` en `lib/domain/` y sus implementaciones concretas en `lib/data/`.
- El dominio no debe importar Flutter ni detalles de interfaz o plataforma.
- `CalcularDivision` debe recibir la estrategia mediante la abstracción del dominio y delegar en ella el redondeo, sin seleccionar implementaciones concretas mediante comprobaciones de tipo o un `switch` sobre la estrategia.
- La presentación debe adaptar las entradas, mostrar los estados y presentar los resultados; no debe contener reglas de cálculo.
- `lib/main.dart` será el único punto de composición de las estrategias concretas y sus dependencias.
- Aplicar null safety y usar nombres en español para clases, métodos y variables del dominio.
- No agregar paquetes externos.
- Mantener la aplicación offline y de una sola pantalla.
- Aplicar los principios SOLID de forma proporcional al ejercicio, con decisiones justificadas y código que el estudiante pueda explicar.
- No crear abstracciones adicionales que no aporten valor a los requisitos ni a la arquitectura exigida.
- No modificar las carpetas de plataforma, las dependencias ni los tests existentes sin autorización explícita.

## 9. Criterios de éxito

- **SC-001:** Los 13 escenarios de aceptación de las historias 1 a 3 producen los resultados o mensajes especificados.
- **SC-002:** El 100 % de las reglas de validación y cálculo del dominio tiene pruebas automatizadas.
- **SC-003:** El 100 % de las interacciones visibles principales tiene pruebas de widget o pruebas automatizadas equivalentes.
- **SC-004:** El flujo completo funciona sin conexión y la aplicación no realiza llamadas de red durante la entrada, el cálculo ni el cambio de modo.
- **SC-005:** `flutter analyze` y `flutter test` terminan correctamente antes de aceptar la implementación.

## 10. Supuestos

- El monto y la propina se expresan en la moneda indicada por la interfaz; no se requiere selector de moneda.
- La entrada decimal utiliza punto; la coma no se admite como separador decimal.
- El resultado se recalcula automáticamente; no existe una acción separada para confirmar el cálculo.
- No se requiere guardar historiales, perfiles, datos personales ni resultados entre sesiones.
- No se requieren servicios externos ni persistencia.
- La implementación se realizará después de aprobar esta especificación y de completar la revisión del plan y las tareas correspondientes.
