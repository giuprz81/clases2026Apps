# Constitucion del proyecto: divisor_cuenta

Esta Constitucion es la fuente de verdad para las decisiones posteriores de especificacion, arquitectura, implementacion y pruebas de la app Flutter `divisor_cuenta`, una aplicacion de una sola pantalla para dividir una cuenta.

## Principios permanentes

### I. SOLID demostrable

Todo cambio debe aplicar SOLID de forma demostrable:

- **Single Responsibility Principle:** cada clase, metodo y modulo debe tener una responsabilidad clara y una sola razon principal para cambiar.
- **Open/Closed Principle:** las reglas y componentes deben poder extenderse sin modificar comportamiento estable; las nuevas variaciones deben apoyarse en abstracciones.
- **Liskov Substitution Principle:** toda implementacion debe poder sustituir su abstraccion sin romper las expectativas del contrato.
- **Interface Segregation Principle:** definir interfaces pequenas y enfocadas; los consumidores no deben depender de metodos que no usan.
- **Dependency Inversion Principle:** las capas de alto nivel deben depender de abstracciones, no de implementaciones concretas; las dependencias deben inyectarse cuando corresponda.

La especificacion, el plan y la revision de cada cambio deben indicar como se cumplen los principios SOLID relevantes.

### II. Arquitectura por capas

La arquitectura debe mantener la direccion de dependencias:

`presentation -> domain <- data`

`presentation` contiene la interfaz y el estado de presentacion. `domain` contiene entidades, contratos y reglas de negocio. `data` implementa los contratos del dominio y cualquier acceso a datos necesario. No se permite una dependencia directa de `presentation` hacia detalles concretos de `data` cuando pueda depender de un contrato del dominio.

### III. Dominio independiente de Flutter

El dominio no debe importar Flutter, Material, widgets, plugins, APIs de plataforma ni detalles de interfaz. Las reglas de negocio deben ejecutarse y probarse sin depender de un entorno Flutter.

### IV. Separacion entre negocio e interfaz

Las reglas para calcular totales, propinas y montos por persona deben permanecer separadas de widgets, controladores de texto, navegacion y estilos. La interfaz solo adapta entradas y presenta resultados mediante contratos del dominio.

### V. Null safety y nomenclatura del dominio

Todo codigo nuevo o modificado debe usar null safety. Las clases, metodos y variables del dominio deben tener nombres en espanol, claros y consistentes. Las excepciones tecnicas de nombres externos solo se permiten cuando una API o contrato externo lo exija.

### VI. Dependencias justificadas

No se deben agregar paquetes externos. Una excepcion requiere una justificacion explicita en la especificacion, incluyendo el problema que resuelve, por que no basta la libreria estandar o Flutter, y el impacto de mantenimiento y seguridad.

### VII. Una sola pantalla

La aplicacion debe mantenerse como una experiencia de una sola pantalla. No se agregaran rutas, pantallas o flujos secundarios salvo que una futura especificacion modifique explicitamente este principio y documente su impacto.

### VIII. Calidad y pruebas automatizadas

La solucion debe ser testeable. Cada requisito funcional nuevo debe contar con pruebas automatizadas apropiadas, priorizando pruebas unitarias para el dominio y pruebas de widget para el comportamiento visible. Los tests existentes no deben modificarse para ocultar regresiones; las pruebas nuevas deben agregarse de forma compatible.

### IX. Seguridad y minimizacion de datos

Aplicar buenas practicas de seguridad. No almacenar informacion sensible innecesaria. Los datos de la cuenta deben permanecer en memoria salvo una especificacion posterior que justifique su persistencia, defina su proteccion y documente su ciclo de vida.

### X. Comprension del estudiante

El estudiante debe poder explicar cualquier funcion generada por el agente. Cada implementacion debe ser simple, legible y proporcional al problema. No se aceptara codigo generado que el estudiante no pueda justificar, mantener o modificar.

## Restricciones del proyecto

- No modificar las carpetas de plataforma `android`, `ios`, `linux`, `macos`, `web` o `windows` para resolver requisitos de la app, salvo autorizacion explicita.
- No modificar pruebas existentes, dependencias o configuracion del proyecto sin autorizacion explicita.
- Los cambios deben respetar `AGENTS.md` y esta Constitucion; en caso de conflicto, detenerse y documentar la discrepancia.

## Puertas de calidad

Antes de considerar terminado un cambio de codigo, ejecutar desde la raiz de `divisor_cuenta`:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Todo fallo debe corregirse o documentarse explicitamente antes de entregar el cambio.

## Gobernanza

Esta Constitucion prevalece sobre convenciones informales del proyecto. Toda modificacion requiere actualizar este archivo, indicar la razon del cambio y aumentar la version. Las especificaciones, planes, tareas, revisiones y pruebas deben comprobar el cumplimiento de los principios aplicables. Las excepciones deben estar autorizadas y documentadas con su alcance, motivo y plan de retirada.

**Version**: 1.0.0 | **Ratificada**: 2026-10-08 | **Ultima enmienda**: 2026-10-08
