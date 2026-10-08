# Guia de validacion de la feature

## Prerrequisitos

- Flutter y Dart disponibles en el entorno.
- Ejecutar los comandos desde la raiz de `divisor_cuenta`.
- No se requiere internet, backend ni configuracion adicional.

## Comandos

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Verificacion manual

1. Abrir la aplicacion; debe mostrarse una sola pantalla.
2. Introducir `100`, `4`, `10` y seleccionar `Exacto`; comprobar `27.50`.
3. Introducir `90`, `3`, `0` y mantener `Exacto`; comprobar `30.00`.
4. Introducir `50` y `0` personas; comprobar `Debe haber al menos una persona` sin resultado.
5. Introducir `abc` como monto; comprobar `Monto invalido` sin resultado.
6. Introducir `10`, `3`, `0` en `Exacto`; comprobar `3.33`.
7. Cambiar a `Redondeo hacia arriba`; comprobar `4.00` sin pulsar ningun boton de calculo.
8. Repetir el flujo sin conexion y comprobar que no se requiere ninguna solicitud de red.
