# Investigacion: Divisor de cuenta

## Decision 1: calculo local sin persistencia

**Decision**: ejecutar todo el calculo en memoria dentro del caso de uso del dominio.

**Motivo**: los requisitos son deterministas, no necesitan datos externos y la aplicacion debe funcionar completamente offline. Evita superficie de seguridad, dependencias y complejidad innecesarias.

## Decision 2: redondeo monetario en dos etapas

**Decision**: calcular primero el total con propina y dividirlo entre las personas. En modo Exacto se aplica redondeo convencional a dos decimales. En modo Redondeo hacia arriba se aplica techo al importe por persona y se presenta con dos decimales.

**Motivo**: coincide con los seis criterios de aceptacion, en particular `10 / 3 -> 3.33` y `10 / 3 -> 4.00` segun el modo.

## Decision 3: validacion en el dominio

**Decision**: el dominio recibira valores tipados cuando sean parseables y devolvera un resultado de exito o un error de negocio conocido.

**Motivo**: mantiene los widgets libres de reglas, hace las validaciones testeables sin Flutter y permite que la presentacion traduzca entradas de texto a valores.

## Decision 4: actualizacion reactiva sin boton

**Decision**: cada cambio de monto, personas, propina o modo invocara el caso de uso y actualizara el estado visible.

**Motivo**: es un requisito explicito y mantiene el flujo de una sola pantalla claro.

## Alternativas descartadas

- Persistencia local: no aporta valor al alcance y contradice la minimizacion de datos.
- Paquetes de gestion de estado o decimal: no son necesarios para una pantalla y violarian la restriccion de dependencias sin justificacion.
- Servicio remoto: contradice el funcionamiento offline.
- Boton de calculo: contradice la actualizacion automatica.
