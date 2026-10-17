# Contrato del caso de uso de cálculo

## Nombre

`CalcularDivision`

## Responsabilidad

Calcular la propina, el total de la cuenta y el importe individual, después de validar los valores tipados recibidos. El caso de uso no depende de Flutter, no accede a la red y no persiste datos.

## Entrada

Una solicitud con:

- `monto`: número decimal mayor o igual a cero.
- `personas`: número entero mayor o igual a uno.
- `propinaPorcentaje`: número entre `0` y `100`, inclusive.
- `modoRedondeo`: `exacto` o `redondeoHaciaArriba`.

La conversión desde campos de texto se realiza antes de invocar el caso de uso. La presentación rechazará entradas vacías, no numéricas y formatos no admitidos. El punto es el único separador decimal permitido; un monto como `12,50` debe mostrar `Monto invalido`.

## Reglas de cálculo

1. La propina se calcula como `monto * porcentaje / 100`.
2. El total se calcula como `monto + propina`.
3. El importe base individual se calcula como `total / personas`, después de validar que `personas >= 1`.
4. En modo `exacto`, el importe individual se presenta con redondeo decimal de mitad hacia arriba a dos decimales.
5. En modo `redondeoHaciaArriba`, se aplica techo matemático al importe base individual y se presenta el resultado con dos decimales. Un importe base entero permanece igual.
6. La implementación no debe depender de coincidencias accidentales de la representación binaria de `double` para decidir un empate decimal.

## Salida exitosa

`ResultadoDivision` contiene:

- `totalCuenta`;
- `propina`;
- `montoPorPersona`;
- `modoRedondeo`.

La presentación debe mostrar el importe individual con exactamente dos decimales. Si existe una entrada inválida, no debe mostrarse un importe individual calculado.

## Salida de validación

Los mensajes públicos deben coincidir exactamente con los siguientes:

- Monto vacío, no numérico o con coma decimal: `Monto invalido`.
- Monto negativo: `El monto no puede ser negativo`.
- Personas igual a cero o negativas: `Debe haber al menos una persona`.
- Personas no enteras: `El número de personas debe ser un entero`.
- Propina vacía o no numérica: `Propina invalida`.
- Propina menor que cero o mayor que cien: `La propina debe estar entre 0 y 100`.

La presentación puede detectar errores de formato antes de construir la entrada tipada. El dominio valida las condiciones de negocio de los valores que recibe.

## Invariantes y ejemplos

- No se divide entre cero ni con un número negativo de personas.
- No se realizan llamadas de red ni persistencia.
- El caso de uso no importa Flutter.
- Monto `100`, 4 personas y propina `10%`, modo `exacto`: `27.50`.
- Monto `90`, 3 personas y propina `0%`, modo `exacto`: `30.00`.
- Monto `10`, 3 personas y propina `0%`, modo `exacto`: `3.33`.
- Monto `10`, 3 personas y propina `0%`, modo `redondeoHaciaArriba`: `4.00`.
- Monto `2.01`, 2 personas y propina `0%`, modo `exacto`: `1.01`, por redondeo decimal de mitad hacia arriba.
- Los resultados visibles tienen exactamente dos decimales.
