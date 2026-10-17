import '../../domain/entities/estrategia_redondeo.dart';

class RedondeoHaciaArriba implements EstrategiaRedondeo {
  const RedondeoHaciaArriba();

  @override
  double redondear(double importe) {
    final parteDecimal = importe - importe.truncate();

    if (parteDecimal == 0) {
      return importe;
    }

    return importe.ceilToDouble();
  }
}
