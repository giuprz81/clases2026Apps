# Investigación: Divisor de cuenta

## Decisión 1: cálculo local sin persistencia

**Decisión**: ejecutar todo el cálculo en memoria dentro del caso de uso del dominio.

**Motivo**: los requisitos son deterministas, no necesitan datos externos y la aplicación debe funcionar completamente offline. Evita superficie de seguridad, dependencias y complejidad innecesarias.

No se necesita una capa `data`, un repositorio ni persistencia para esta feature. Si en el futuro aparece una necesidad real de datos externos o almacenamiento, la arquitectura se reevaluará como un cambio separado.

## Decisión 2: reglas explícitas de redondeo monetario

**Decisión**: calcular primero la propina como `monto * porcentaje / 100`, sumar la propina al monto y dividir el total entre el número de personas.

En modo `Exacto`, presentar el importe individual con redondeo decimal de mitad hacia arriba a dos decimales. El caso `2.01 / 2 = 1.005` debe mostrarse como `1.01`.

En modo `Redondeo hacia arriba`, aplicar techo matemático al importe individual y presentarlo con dos decimales. Si el importe ya es entero, conservarlo sin aumentarlo.

**Motivo**: estas reglas coinciden con los escenarios de aceptación, incluidos `10 / 3 -> 3.33` en modo `Exacto` y `10 / 3 -> 4.00` en modo `Redondeo hacia arriba`.

**Consideración técnica**: la implementación debe demostrar los resultados decimales esperados y evitar depender de coincidencias accidentales de la representación binaria de `double`. No se agregará un paquete externo de decimales.

## Decisión 3: validación en la frontera de entrada y en el dominio

**Decisión**: la presentación interpretará las cadenas introducidas por la persona usuaria y detectará entradas vacías, no numéricas o con formato no admitido. El dominio recibirá valores tipados y validará las condiciones de negocio antes de calcular.

La aplicación deberá conservar los mensajes públicos definidos en `spec.md`:

- `Monto invalido`
- `El monto no puede ser negativo`
- `Debe haber al menos una persona`
- `El número de personas debe ser un entero`
- `Propina invalida`
- `La propina debe estar entre 0 y 100`

**Motivo**: mantiene los widgets libres de reglas de cálculo, permite probar el dominio sin Flutter y evita que un error de conversión se transforme silenciosamente en un valor válido.

La coma decimal no se admitirá. Un monto como `12,50` deberá producir `Monto invalido`.

## Decisión 4: actualización automática sin botón

**Decisión**: cada cambio de monto, personas, propina o modo invocará el caso de uso cuando las entradas puedan evaluarse y actualizará el estado visible. Si existe un error de validación, se mostrará el mensaje correspondiente y no se presentará un importe individual.

**Motivo**: es un requisito explícito y mantiene claro el flujo de una sola pantalla.

## Decisión 5: arquitectura proporcional

**Decisión**: mantener las dependencias `presentation -> domain`, sin crear una capa `data`, repositorios, interfaces de estrategia ni abstracciones vacías mientras no aporten valor a los requisitos actuales.

**Motivo**: el alcance es una pantalla con cálculo local y dos modos de redondeo. La solución debe demostrar separación de responsabilidades sin introducir complejidad que el estudiante no pueda justificar.

## Alternativas descartadas

- **Persistencia local**: no aporta valor al alcance y contradice la ausencia de historial y almacenamiento.
- **Paquetes de gestión de estado o decimales**: no se incorporarán; la necesidad actual puede resolverse con Flutter y Dart estándar, siempre que las pruebas demuestren el comportamiento decimal requerido.
- **Servicio remoto**: contradice el funcionamiento offline.
- **Botón de cálculo**: contradice la actualización automática.
- **Capa `data` sin función**: no se creará una carpeta o repositorio vacío solo para representar una arquitectura teórica.
- **Abstracción de estrategia para redondeo**: no se justifica para los dos modos actuales; se reevaluaría si los requisitos futuros aumentaran de forma sustancial.
