# Instrucciones para agentes

## Alcance

Esta es una aplicacion Flutter de una sola pantalla para dividir una cuenta entre varias personas.

## Arquitectura

- Usar arquitectura por capas con la direccion de dependencias: `presentation -> domain <- data`.
- La capa `presentation` contiene widgets, estado de interfaz y adaptacion de entradas del usuario.
- La capa `domain` contiene entidades, reglas de negocio y contratos necesarios.
- La capa `data` implementa contratos del dominio y maneja fuentes de datos si fueran necesarias.
- El dominio no debe importar ni depender de Flutter, Material, widgets ni detalles de plataforma.

## Codigo

- Aplicar null safety en todo codigo nuevo o modificado.
- Usar nombres en espanol para las clases, metodos y variables de la capa de dominio.
- No agregar paquetes externos ni modificar las dependencias existentes.
- Mantener la aplicacion en una sola pantalla, salvo instruccion explicita contraria.

## Archivos protegidos

- No modificar los tests existentes.
- No modificar `pubspec.yaml`, `pubspec.lock` ni otras dependencias.
- No modificar las carpetas `android`, `ios`, `linux`, `macos`, `web` o `windows`.

## Validacion

Antes de finalizar cambios de codigo, ejecutar desde la raiz del proyecto:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```
