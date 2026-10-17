# Modelo de datos del dominio

## EntradaCuenta

Representa los valores numéricos necesarios para una división válida.

- `monto`: número decimal mayor o igual a cero.
- `personas`: número entero mayor o igual a uno.
- `propinaPorcentaje`: número entre cero y cien, inclusive.
- `modoRedondeo`: `exacto` o `redondeoHaciaArriba`.

La conversión desde texto se realiza en la frontera de presentación. Una entrada vacía, no numérica o con un formato no admitido no debe convertirse silenciosamente en un valor válido. La coma decimal no está admitida.

La entidad representa una entrada válida. Por tanto, el texto `2.5` debe identificarse como número de personas no entero antes de construir una `EntradaCuenta` válida.

## ModoRedondeo

Enumeración de dominio con exactamente dos opciones:

- `exacto`: calcular el importe base por persona y presentarlo con redondeo decimal de mitad hacia arriba a dos decimales.
- `redondeoHaciaArriba`: aplicar techo matemático al importe base por persona y presentarlo con dos decimales. Si el importe base ya es entero, conservarlo sin aumentarlo.

## ResultadoDivision

Representa un cálculo exitoso:

- `totalCuenta`: monto más propina.
- `propina`: valor monetario de la propina.
- `montoPorPersona`: importe individual después de aplicar el modo.
- `modoRedondeo`: modo utilizado.

Solo debe producirse un resultado exitoso cuando todas las entradas sean válidas. La presentación mostrará el importe por persona con exactamente dos decimales.

## ErrorDivision

Representa una condición de validación que impide producir un importe individual. Las categorías internas deberán permitir presentar los siguientes mensajes públicos sin ambigüedad:

| Categoría conceptual | Mensaje público |
|---|---|
| Monto vacío, no numérico o con formato no admitido, incluida la coma decimal | `Monto invalido` |
| Monto negativo | `El monto no puede ser negativo` |
| Número de personas igual a cero o negativo | `Debe haber al menos una persona` |
| Número de personas no entero | `El número de personas debe ser un entero` |
| Propina vacía o no numérica | `Propina invalida` |
| Propina menor que cero o mayor que cien | `La propina debe estar entre 0 y 100` |

La presentación puede detectar errores de formato antes de construir una entrada de dominio. El dominio debe validar los valores tipados que recibe. No es obligatorio que todos los errores se generen en la misma capa, pero el mensaje público debe coincidir con la especificación.

## Relaciones y flujo

`Texto de entrada` -> `validación y conversión en presentación` -> `EntradaCuenta` -> `CalcularDivision` -> `ResultadoDivision` o error de negocio -> `estado visible`.

No hay almacenamiento ni relaciones persistentes. El dominio no importa Flutter ni detalles de plataforma.
