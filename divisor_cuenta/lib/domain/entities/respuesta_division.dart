import 'resultado_division.dart';
import '../errors/error_division.dart';

sealed class RespuestaDivision {
  const RespuestaDivision();
}

class DivisionExitosa extends RespuestaDivision {
  final ResultadoDivision resultado;

  const DivisionExitosa(this.resultado);
}

class DivisionFallida extends RespuestaDivision {
  final ErrorDivision error;

  const DivisionFallida(this.error);
}
