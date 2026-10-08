# Modelo de datos del dominio

## EntradaCuenta

Representa los valores numericos necesarios para una division.

- `monto`: numero decimal mayor o igual a cero.
- `personas`: numero entero mayor o igual a uno.
- `propinaPorcentaje`: numero entre cero y cien, inclusive.
- `modoRedondeo`: `exacto` o `redondeoHaciaArriba`.

La entidad solo puede representar una entrada valida. La conversion desde texto y la produccion de mensajes de validacion pertenecen a la frontera de presentacion y al caso de uso, respectivamente, sin importar Flutter en el dominio.

## ModoRedondeo

Enumeracion de dominio:

- `exacto`: redondeo monetario convencional a dos decimales.
- `redondeoHaciaArriba`: techo del importe por persona al siguiente entero, presentado con dos decimales.

## ResultadoDivision

Representa un calculo exitoso:

- `totalCuenta`: monto mas propina.
- `propina`: valor monetario de la propina.
- `montoPorPersona`: importe despues de aplicar el modo.
- `modoRedondeo`: modo usado para el calculo.

## ErrorDivision

Representa un calculo no ejecutable con un mensaje de negocio:

- `montoInvalido`: entrada vacia, no numerica, negativa o fuera del rango permitido.
- `personasInvalidas`: numero menor que uno o no entero.
- `propinaInvalida`: porcentaje menor que cero o mayor que cien.

## Relaciones y flujo

`EntradaCuenta` -> `CalcularDivision` -> `ResultadoDivision` o `ErrorDivision`.

No hay almacenamiento ni relaciones persistentes.
