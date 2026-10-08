# Especificacion: Divisor de cuenta

**Feature Branch**: `001-dividir-cuenta`  
**Creada**: 2026-10-08  
**Estado**: Draft  
**Entrada**: Solicitud del usuario para una app Flutter offline de una sola pantalla que divide una cuenta.

## Decisiones aclaradas

- En modo `Exacto`, el importe se redondea de forma monetaria convencional a dos decimales. Por ejemplo, `10 / 3` se muestra como `3.33`.
- El monto valido es mayor o igual a `0`.
- El porcentaje de propina valido esta entre `0%` y `100%`, inclusive.
- El numero de personas valido es cualquier numero entero mayor o igual a `1`; los valores `0` y negativos deben producir el mensaje de validacion correspondiente.
- El resultado se actualiza automaticamente al cambiar cualquier campo o el modo de redondeo. No debe existir un boton `Calcular`.

## Alcance

La aplicacion permitira introducir el monto total, el numero de personas y el porcentaje de propina. Calculara el monto que corresponde a cada persona y permitira elegir entre resultado exacto con dos decimales o redondeo hacia arriba al siguiente entero. La experiencia sera completamente offline y estara contenida en una sola pantalla.

## Historias de usuario y pruebas

### Historia 1 - Dividir una cuenta con resultado exacto (Prioridad: P1)

Como persona que comparte una cuenta, quiero introducir el monto, el numero de personas y la propina para conocer cuanto debe pagar cada persona.

**Por que esta prioridad**: Es el flujo principal y el valor minimo viable de la aplicacion.

**Prueba independiente**: Introducir datos validos y comprobar que el resumen muestra el importe individual correcto con dos decimales.

**Escenarios de aceptacion**:

1. **Dado** un monto de 100, 4 personas, 10% de propina y modo Exacto, **cuando** se calcula la cuenta, **entonces** se muestra `27.50` por persona.
2. **Dado** un monto de 90, 3 personas, 0% de propina y modo Exacto, **cuando** se calcula la cuenta, **entonces** se muestra `30.00` por persona.
3. **Dado** un monto de 10, 3 personas, 0% de propina y modo Exacto, **cuando** se calcula la cuenta, **entonces** se muestra `3.33` por persona.

### Historia 2 - Validar entradas (Prioridad: P1)

Como persona usuaria, quiero recibir mensajes claros cuando los datos no se pueden calcular para corregirlos sin ambiguedad.

**Por que esta prioridad**: Evita resultados invalidos y permite completar el flujo principal de manera segura.

**Prueba independiente**: Introducir valores invalidos y verificar el mensaje correspondiente y la ausencia de un resultado.

**Escenarios de aceptacion**:

1. **Dado** un monto de 50 y 0 personas, **cuando** se intenta calcular, **entonces** se muestra `Debe haber al menos una persona` y no se muestra un resultado por persona.
2. **Dado** el texto `abc` como monto, **cuando** se intenta calcular, **entonces** se muestra `Monto invalido` y no se muestra un resultado por persona.

### Historia 3 - Elegir redondeo (Prioridad: P2)

Como persona usuaria, quiero elegir la forma de redondear para adaptar el resultado a la forma de pago del grupo.

**Por que esta prioridad**: Es una necesidad explicita del producto despues del calculo exacto basico.

**Prueba independiente**: Seleccionar cada modo con los mismos datos y comprobar que el importe mostrado respeta su contrato.

**Escenarios de aceptacion**:

1. **Dado** un monto de 10, 3 personas, 0% de propina y modo Exacto, **cuando** se calcula, **entonces** se muestra `3.33`.
2. **Dado** un monto de 10, 3 personas, 0% de propina y modo Redondeo hacia arriba, **cuando** se calcula, **entonces** se muestra `4.00`.

### Historia 4 - Funcionamiento offline (Prioridad: P2)

Como persona usuaria, quiero usar el divisor sin conexion para calcular la cuenta en cualquier lugar.

**Por que esta prioridad**: El calculo es local y no debe depender de disponibilidad de red.

**Prueba independiente**: Ejecutar el flujo sin acceso de red y comprobar que las entradas, el calculo y el resultado siguen funcionando.

**Escenarios de aceptacion**:

1. **Dado** que el dispositivo no tiene conexion, **cuando** se introducen datos validos, **entonces** se puede obtener el resultado sin solicitudes de red ni mensajes de conectividad.

## Requisitos funcionales

- **FR-001**: La aplicacion MUST presentar una unica pantalla para el flujo completo.
- **FR-002**: La aplicacion MUST permitir introducir un monto total de cuenta.
- **FR-003**: La aplicacion MUST permitir introducir el numero de personas, incluyendo temporalmente valores invalidos para poder mostrar su validacion.
- **FR-004**: La aplicacion MUST permitir introducir un porcentaje de propina y validar que este entre 0 y 100, inclusive.
- **FR-004a**: La aplicacion MUST validar que el monto sea numerico y mayor o igual a 0.
- **FR-004b**: La aplicacion MUST validar que el numero de personas sea un entero mayor o igual a 1.
- **FR-005**: La aplicacion MUST calcular el total sumando al monto la propina porcentual.
- **FR-006**: La aplicacion MUST calcular el importe base por persona dividiendo el total entre el numero de personas.
- **FR-007**: La aplicacion MUST ofrecer exactamente los modos `Exacto` y `Redondeo hacia arriba`.
- **FR-008**: En modo `Exacto`, la aplicacion MUST aplicar redondeo monetario convencional y mostrar el importe por persona con exactamente dos decimales.
- **FR-009**: En modo `Redondeo hacia arriba`, la aplicacion MUST redondear hacia arriba el importe por persona al siguiente valor entero y mostrarlo con dos decimales.
- **FR-010**: Si el numero de personas es menor que 1, la aplicacion MUST mostrar `Debe haber al menos una persona` y no mostrar un importe por persona.
- **FR-011**: Si el monto no puede interpretarse como numero, la aplicacion MUST mostrar `Monto invalido` y no mostrar un importe por persona.
- **FR-012**: La aplicacion MUST recalcular y actualizar automaticamente el resultado cuando cambie cualquier campo o el modo de redondeo; no debe requerir un boton `Calcular`.
- **FR-013**: La aplicacion MUST realizar todos los calculos localmente y no requerir red, cuenta, backend ni persistencia de datos.
- **FR-014**: Las reglas de calculo y validacion MUST estar separadas de la interfaz de usuario y ubicarse en el dominio independiente de Flutter.
- **FR-015**: La solucion MUST incluir pruebas automatizadas para cada requisito funcional y escenario de aceptacion relevante.

## Reglas de calculo

- La propina se calcula como `monto * porcentaje / 100`.
- El total se calcula como `monto + propina`.
- El importe base por persona se calcula como `total / personas` despues de validar que `personas >= 1`.
- El modo Exacto conserva el resultado calculado y lo presenta con dos decimales.
- El modo Redondeo hacia arriba aplica techo matematico al importe por persona y lo presenta con dos decimales; por ejemplo, `3.333...` se muestra como `4.00`.
- Una entrada vacia, no numerica o con un formato que no pueda convertirse a numero se considera un monto invalido.

## Casos limite

- Monto vacio o formado solo por espacios: mostrar `Monto invalido`.
- Monto `abc` o cualquier texto no numerico: mostrar `Monto invalido`.
- Monto negativo: mostrar un mensaje de validacion y no mostrar un importe por persona.
- Numero de personas igual a 0 o negativo: mostrar `Debe haber al menos una persona`.
- Propina igual a 0: calcular sin cargo adicional.
- Propina menor que 0 o mayor que 100: mostrar un mensaje de validacion y no mostrar un importe por persona.
- Resultado exacto entero: mantener dos decimales, por ejemplo `30.00`.
- Resultado exacto con fraccion: aplicar redondeo monetario convencional a dos decimales; por ejemplo, `10 / 3` se muestra como `3.33`.
- Cambio de modo con entradas invalidas: mantener el mensaje de validacion y no mostrar un resultado.
- Sin conexion: el flujo no debe fallar ni intentar acceder a servicios externos.

## Entidades y conceptos del dominio

- **EntradaCuenta**: monto, numero de personas y porcentaje de propina introducidos por la persona usuaria.
- **ModoRedondeo**: enumeracion de dominio con `exacto` y `redondeoHaciaArriba`.
- **ResultadoDivision**: total calculado, importe por persona y modo aplicado.
- **ErrorDivision**: resultado de validacion con los mensajes de negocio definidos.

## Arquitectura y restricciones

- Mantener la direccion de dependencias `presentation -> domain <- data`.
- El dominio no debe importar Flutter ni detalles de interfaz o plataforma.
- La presentacion debe adaptar entradas y mostrar estados; no debe contener reglas de calculo.
- No se requieren fuentes de datos ni persistencia; la capa `data` solo se creara si una especificacion posterior la necesita.
- Aplicar null safety y usar nombres en espanol para clases, metodos y variables del dominio.
- No agregar paquetes externos.
- Mantener la aplicacion offline y de una sola pantalla.
- Las decisiones de diseño deben demostrar los principios SOLID de la Constitucion y producir codigo que el estudiante pueda explicar.
- No modificar las carpetas de plataforma, dependencias ni tests existentes sin autorizacion explicita.

## Criterios de exito

- **SC-001**: Los seis casos numericos de aceptacion producen exactamente los valores y mensajes especificados.
- **SC-002**: El 100% de las reglas de validacion y calculo del dominio tiene pruebas automatizadas.
- **SC-003**: El 100% de las interacciones visibles principales tiene pruebas de widget o pruebas automatizadas equivalentes.
- **SC-004**: El flujo completo funciona sin conexion y no realiza llamadas de red.
- **SC-005**: `flutter analyze` y `flutter test` terminan correctamente antes de aceptar la implementacion.

## Supuestos

- El monto y la propina se expresan en la moneda local mostrada por la interfaz; la especificacion no requiere selector de moneda.
- La entrada decimal puede usar punto y, de forma conveniente, coma como separador decimal si la interfaz lo admite.
- El resultado se recalcula en vivo; no existe una accion separada para confirmar el calculo.
- No se requiere guardar historiales, perfiles, datos personales ni resultados entre sesiones.
- La implementacion se realizara despues de aprobar esta especificacion y de completar el plan y las tareas correspondientes.
