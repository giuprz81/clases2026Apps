import '../../domain/entities/estrategia_redondeo.dart';

class RedondeoExacto implements EstrategiaRedondeo {
  const RedondeoExacto();

  @override
  double redondear(double importe) {
    final escalado = importe * 100;
    final base = escalado.floorToDouble();
    final fraccion = escalado - base;

    // Tolerancia para reducir errores de representación binaria.
    const tolerancia = 1e-9;

    final redondeado = fraccion >= 0.5 - tolerancia ? base + 1 : base;

    return redondeado / 100;
  }
}
