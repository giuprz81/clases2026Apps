# Plan de implementacion: Divisor de cuenta

**Branch**: `001-dividir-cuenta`  
**Fecha**: 2026-10-08  
**Especificacion**: [spec.md](./spec.md)

## Resumen

Implementar una app Flutter offline de una sola pantalla que valide monto, personas y propina, calcule el total y el valor por persona, y aplique uno de dos modos de redondeo. La logica se aislara en el dominio sin dependencias de Flutter; la presentacion adaptara entradas y estados; no se necesita persistencia ni una fuente de datos externa.

## Contexto tecnico

**Lenguaje/version**: Dart con null safety, segun el SDK declarado en `pubspec.yaml`.

**Dependencias primarias**: Flutter SDK y libreria estandar de Dart. No se agregaran paquetes externos.

**Almacenamiento**: N/A. Todos los datos viven en memoria durante la sesion.

**Pruebas**: `flutter_test`, pruebas unitarias del dominio y pruebas de widget para la pantalla.

**Plataforma objetivo**: Flutter multiplataforma existente; el flujo no depende de una plataforma concreta.

**Tipo de proyecto**: App movil/desktop/web Flutter de una sola pantalla.

**Objetivo de rendimiento**: recalculo inmediato tras cada cambio de entrada o modo, sin operaciones de red ni bloqueos perceptibles.

**Restricciones**: completamente offline, sin persistencia, sin boton Calcular, una sola pantalla, sin paquetes externos y respetando las carpetas de plataforma protegidas.

**Escala/alcance**: una pantalla, un caso de uso de calculo, dos modos de redondeo y validaciones locales.

## Comprobacion de la Constitucion

- **SOLID**: `CalcularDivision` tendra una responsabilidad; `ModoRedondeo` y una abstraccion de estrategia permitiran extender modos sin acoplar la presentacion; contratos pequenos separaran calculo y formateo; la presentacion dependera del caso de uso, no de detalles concretos.
- **Capas**: se usara `presentation -> domain <- data`. Como no existe almacenamiento ni servicio externo, `data` no tendra implementacion funcional en esta feature.
- **Dominio independiente**: los archivos de `lib/domain` solo importaran Dart estandar.
- **Negocio separado de UI**: validacion, propina, division y redondeo viviran en el dominio.
- **Null safety y espanol**: todo codigo nuevo usara null safety y nombres espanoles en el dominio.
- **Dependencias**: no se agregaran paquetes.
- **Una pantalla/offline**: no se agregaran rutas ni llamadas de red.
- **Pruebas**: cada criterio de aceptacion tendra cobertura unitaria y/o de widget.
- **Seguridad**: no se persistiran datos sensibles ni datos de cuenta.
- **Comprension del estudiante**: se preferiran tipos y funciones pequenas, explicables y sin abstracciones innecesarias.

**Resultado de la puerta**: APROBADA. No se identifican violaciones ni excepciones que justificar.

## Estructura del proyecto

### Documentacion de esta feature

```text
.specify/specs/001-dividir-cuenta/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    └── calculo-division.md
```

### Codigo fuente

```text
lib/
├── main.dart
├── domain/
│   ├── entities/
│   │   ├── entrada_cuenta.dart
│   │   └── resultado_division.dart
│   ├── enums/
│   │   └── modo_redondeo.dart
│   ├── errors/
│   │   └── error_division.dart
│   └── use_cases/
│       └── calcular_division.dart
├── presentation/
│   ├── pages/
│   │   └── divisor_cuenta_page.dart
│   ├── controllers/
│   │   └── divisor_cuenta_controller.dart
│   └── widgets/
│       ├── entrada_cuenta_form.dart
│       └── resumen_division.dart
└── data/
    └── README.md

test/
├── domain/
│   └── calcular_division_test.dart
└── presentation/
    └── divisor_cuenta_page_test.dart
```

**Decision de estructura**: separar explicitamente `domain`, `presentation` y `data` dentro de `lib`. `main.dart` solo configurara el punto de entrada y la inyeccion del caso de uso. La carpeta `data` queda documentada pero sin repositorios porque la feature no requiere datos externos.

## Secuencia de implementacion

1. Crear los tipos puros del dominio para entrada, modo, resultado y error.
2. Implementar el caso de uso de calculo con validacion y redondeo monetario convencional.
3. Crear el controlador de presentacion que convierta texto a valores, invoque el dominio en cada cambio y exponga estados de resultado o error.
4. Construir la unica pantalla y sus widgets, incluyendo campos, selector de modo, mensajes y resumen.
5. Conectar `main.dart` mediante inyeccion explicita del caso de uso.
6. Agregar pruebas unitarias para todos los escenarios numericos y de validacion, y pruebas de widget para actualizacion automatica y controles.
7. Ejecutar formato, analisis y pruebas; corregir cualquier incumplimiento antes de entregar.

## Complejidad

No hay violaciones de la Constitucion ni complejidad adicional que justificar.
