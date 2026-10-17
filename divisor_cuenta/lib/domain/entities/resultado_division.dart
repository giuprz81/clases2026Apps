import '../enums/modo_redondeo.dart';

class ResultadoDivision {
  final double totalCuenta;
  final double propina;
  final double montoPorPersona;
  final ModoRedondeo modoRedondeo;

  const ResultadoDivision({
    required this.totalCuenta,
    required this.propina,
    required this.montoPorPersona,
    required this.modoRedondeo,
  });
}
