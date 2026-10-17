# Plan de implementación: Divisor de cuenta

**Branch**: `001-dividir-cuenta`  
**Fecha**: 2026-10-08  
**Especificación**: [spec.md](./spec.md)

## Resumen

Implementar una aplicación Flutter offline de una sola pantalla que valide monto, número de personas y propina, calcule el total y el importe por persona, y aplique uno de dos modos de redondeo. La lógica de negocio estará aislada en el dominio, sin dependencias de Flutter. La presentación adaptará entradas, mostrará errores y resultados. No se necesita persistencia ni una fuente de datos externa.

## Contexto técnico

**Lenguaje/versión**: Dart con null safety, según el SDK declarado en `pubspec.yaml`.

**Dependencias primarias**: Flutter SDK y biblioteca estándar de Dart. No se agregarán paquetes externos.

**Almacenamiento**: No aplica. Todos los datos viven en memoria durante la sesión.

**Pruebas**: `flutter_test`, pruebas unitarias del dominio y pruebas de widget para la pantalla.

**Plataforma objetivo**: Flutter multiplataforma existente; el flujo no depende de una plataforma concreta.

**Tipo de proyecto**: Aplicación Flutter móvil/desktop/web de una sola pantalla.

**Objetivo de rendimiento**: recalcular inmediatamente tras cada cambio de entrada o modo, sin operaciones de red ni bloqueos perceptibles.

**Restricciones**: completamente offline, sin persistencia, sin botón `Calcular`, una sola pantalla, sin paquetes externos y respetando las carpetas de plataforma protegidas.

**Escala/alcance**: una pantalla, un caso de uso de cálculo, dos modos de redondeo y validaciones locales.

## Comprobación de la Constitución

- **SOLID**: aplicar los principios de forma proporcional al ejercicio. `CalcularDivision` tendrá la responsabilidad de ejecutar las reglas de negocio. Se evitarán interfaces, estrategias y contratos adicionales que no aporten valor demostrable a los requisitos actuales.
- **Capas**: mantener la dirección de dependencias `presentation -> domain`. No crear la capa `data` mientras no exista una necesidad real de acceso a fuentes de datos o persistencia.
- **Dominio independiente**: los archivos de `lib/domain` solo importarán Dart estándar; no importarán Flutter ni detalles de interfaz o plataforma.
- **Negocio separado de UI**: las reglas de cálculo y validación de negocio estarán en el dominio. La presentación convertirá las entradas de texto, mostrará estados y presentará los resultados.
- **Null safety y español**: el código nuevo usará null safety y nombres en español para clases, métodos y variables del dominio.
- **Dependencias**: no se agregarán paquetes.
- **Una pantalla/offline**: no se agregarán rutas ni llamadas de red.
- **Pruebas**: los escenarios de aceptación y las reglas de cálculo y validación tendrán cobertura automatizada adecuada.
- **Seguridad**: no se persistirán datos de cuenta ni datos personales.
- **Comprensión del estudiante**: se preferirán tipos y funciones pequeñas, explicables y sin abstracciones innecesarias.

**Resultado de la puerta**: APROBADA, sujeto a mantener las restricciones y decisiones descritas en este plan.

## Estructura del proyecto

### Documentación de esta feature

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

### Código fuente previsto para la feature

```text
lib/
├── main.dart
├── domain/
│   ├── entities/
│   │   ├── entrada_cuenta.dart
│   │   ├── resultado_division.dart
│   │   └── estrategia_redondeo.dart
│   ├── errors/
│   │   └── error_division.dart
│   └── use_cases/
│       └── calcular_division.dart
├── data/
│   └── strategies/
│       ├── redondeo_exacto.dart
│       └── redondeo_hacia_arriba.dart
└── presentation/
    ├── pages/
    │   └── divisor_cuenta_page.dart
    ├── controllers/
    │   └── divisor_cuenta_controller.dart
    └── widgets/
        ├── formulario_cuenta.dart
        └── resumen_division.dart

test/
├── domain/
│   └── calcular_division_test.dart
└── presentation/
    ├── divisor_cuenta_controller_test.dart
    └── divisor_cuenta_page_test.dart
```

Esta estructura define una arquitectura con responsabilidades diferenciadas. `domain/` contiene las entidades, los errores de negocio, el caso de uso y la abstracción `EstrategiaRedondeo`. `data/` contiene las implementaciones concretas `RedondeoExacto` y `RedondeoHaciaArriba`.

La capa de dominio no debe importar Flutter ni depender de las implementaciones concretas de redondeo. El caso de uso recibirá la estrategia mediante una abstracción y delegará en ella el comportamiento de redondeo, sin seleccionar implementaciones mediante comprobaciones de tipo o un `switch` sobre el modo.

`main.dart` será el único punto de composición: construirá las estrategias concretas e inyectará las dependencias necesarias. La presentación permitirá seleccionar el modo de redondeo y utilizará la estrategia correspondiente a través de las dependencias recibidas.

No se eliminarán, moverán ni reorganizarán archivos existentes sin autorización explícita. Las rutas definitivas de las pruebas deberán contrastarse con los archivos reales del proyecto antes de crear o mover pruebas.

## Secuencia de implementación

1. Revisar el estado real del proyecto y conservar los archivos y pruebas existentes.
2. Definir `EstrategiaRedondeo` en el dominio con una operación de redondeo claramente especificada.
3. Adaptar `ResultadoDivision` para conservar la información del modo utilizado sin depender de implementaciones concretas.
4. Implementar `RedondeoExacto` y `RedondeoHaciaArriba` en `data/`, respetando las reglas numéricas definidas en la especificación.
5. Adaptar `CalcularDivision` para recibir e invocar la estrategia mediante la abstracción del dominio, manteniendo las validaciones de negocio.
6. Adaptar el controlador y la presentación para actualizar el resultado al cambiar las entradas o el modo seleccionado.
7. Configurar las estrategias y sus dependencias explícitamente desde `main.dart`.
8. Actualizar y ejecutar las pruebas unitarias y de widget, conservando los escenarios funcionales ya cubiertos.
9. Verificar la independencia del dominio, las reglas SOLID y el cumplimiento de la estructura arquitectónica.
10. Ejecutar formato, análisis estático, pruebas automatizadas y compilación Android; corregir los incumplimientos antes de entregar.

## Secuencia de implementación

1. Revisar el estado real del proyecto y los archivos existentes antes de crear archivos nuevos.
2. Crear los tipos de dominio para entrada, modo, resultado y errores de negocio.
3. Implementar el caso de uso de cálculo con validación y las reglas exactas de redondeo.
4. Crear el controlador de presentación que interprete el texto, invoque el dominio al cambiar entradas y exponga estados de resultado o error.
5. Construir la única pantalla y sus widgets, incluyendo campos, selector de modo, mensajes y resumen.
6. Conectar `main.dart` mediante una dependencia explícita del caso de uso.
7. Agregar pruebas unitarias para los escenarios numéricos y de validación, y pruebas de widget para actualización automática, mensajes y controles.
8. Verificar el funcionamiento offline y que la aplicación no realice solicitudes de red.
9. Ejecutar formato, análisis y pruebas; corregir incumplimientos antes de entregar.

## Reglas de cálculo y precisión

- La propina se calcula como `monto * porcentaje / 100`.
- El total se calcula como `monto + propina`.
- El importe base por persona se calcula como `total / personas`, después de validar las entradas.
- En modo `Exacto`, se aplica redondeo decimal de mitad hacia arriba a dos decimales.
- El caso `2.01 / 2 = 1.005` debe mostrarse como `1.01`.
- En modo `Redondeo hacia arriba`, se aplica techo matemático al importe individual y se presenta con dos decimales. Si el importe ya es entero, se conserva sin aumentarlo.
- La implementación y sus pruebas deben evitar depender de coincidencias accidentales de la representación binaria de `double`.

## Complejidad

No se justifica una capa `data`, un repositorio, una interfaz de estrategia ni un paquete externo para el alcance actual. Si surgiera una necesidad real futura, se reevaluará por separado.
