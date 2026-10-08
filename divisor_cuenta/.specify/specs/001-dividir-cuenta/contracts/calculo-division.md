# Contrato del caso de uso de calculo

## Nombre

`CalcularDivision`

## Entrada

Una solicitud con:

- monto decimal `>= 0`;
- personas enteras `>= 1`;
- propina decimal entre `0` y `100`, inclusive;
- modo `exacto` o `redondeoHaciaArriba`.

## Salida exitosa

`ResultadoDivision` con monto, propina, total e importe por persona. El importe debe ser presentado por la capa de presentacion con dos decimales.

## Salida de validacion

`ErrorDivision` con uno de estos mensajes publicos:

- `Monto invalido`;
- `Debe haber al menos una persona`;
- mensaje equivalente para una propina fuera del rango permitido.

## Invariantes

- No se divide entre cero.
- No se realizan llamadas de red ni persistencia.
- El caso de uso no importa Flutter.
- El modo Exacto produce `27.50` para monto `100`, personas `4`, propina `10`.
- El modo Exacto produce `3.33` para monto `10`, personas `3`, propina `0`.
- El modo Redondeo hacia arriba produce `4.00` para monto `10`, personas `3`, propina `0`.
