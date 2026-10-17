# Guía de validación de la feature

## Prerrequisitos

- Flutter y Dart disponibles en el entorno.
- Ejecutar los comandos desde la raíz de `divisor_cuenta`.
- No se requiere backend, internet ni configuración adicional para calcular.
- No modificar dependencias, carpetas de plataforma ni tests existentes sin autorización explícita.

## Comandos

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Los tres comandos deben terminar correctamente antes de aceptar la feature.

## Verificación manual de cálculos

1. Abrir la aplicación; debe mostrarse una sola pantalla.
2. Introducir monto `100`, `4` personas, `10` de propina y seleccionar `Exacto`; comprobar `27.50`.
3. Introducir monto `90`, `3` personas y `0` de propina en `Exacto`; comprobar `30.00`.
4. Introducir monto `10`, `3` personas y `0` de propina en `Exacto`; comprobar `3.33`.
5. Con los mismos valores, cambiar a `Redondeo hacia arriba`; comprobar `4.00` sin pulsar un botón de cálculo.
6. Introducir monto `2.01`, `2` personas y `0` de propina en `Exacto`; comprobar `1.01`.
7. Confirmar que todos los importes visibles tienen exactamente dos decimales.

## Verificación manual de validaciones

1. Introducir `50` y `0` personas; comprobar `Debe haber al menos una persona` y que no se muestre un importe individual.
2. Introducir un número negativo de personas; comprobar `Debe haber al menos una persona`.
3. Introducir un monto vacío, solo espacios o `abc`; comprobar `Monto invalido`.
4. Introducir un monto negativo; comprobar `El monto no puede ser negativo`.
5. Introducir `12,50` como monto; comprobar `Monto invalido`.
6. Introducir `2.5` como número de personas; comprobar `El número de personas debe ser un entero`.
7. Introducir una propina vacía o no numérica; comprobar `Propina invalida`.
8. Introducir una propina menor que `0` o mayor que `100`; comprobar `La propina debe estar entre 0 y 100`.
9. Confirmar que una propina de `0` se acepta y no añade importe.
10. Confirmar que una propina de `100` se acepta.
11. Cambiar el modo mientras hay entradas inválidas; mantener el mensaje de validación y no mostrar un importe individual.

## Verificación offline

1. Desconectar el dispositivo o entorno de prueba de la red.
2. Introducir datos válidos y comprobar que se calcula el importe individual.
3. Cambiar el modo de redondeo y comprobar que el resultado se actualiza.
4. Confirmar que no aparecen mensajes de conectividad y que el flujo no realiza solicitudes de red.

La prueba automatizada offline debe verificar el flujo local y la ausencia de solicitudes de red; no basta con que la prueba simplemente omita configurar un cliente de red.

## Cobertura

La revisión de aceptación debe confirmar:

- los 13 escenarios de las historias 1, 2 y 3 de `spec.md`;
- el escenario offline de la historia 4;
- las reglas adicionales de validación y casos límite enumeradas en esta guía;
- ejecución satisfactoria de formato, análisis estático y pruebas automatizadas.
