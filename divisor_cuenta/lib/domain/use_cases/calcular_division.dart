import '../entities/entrada_cuenta.dart';
import '../entities/estrategia_redondeo.dart';
import '../entities/resultado_division.dart';
import '../entities/respuesta_division.dart';
import '../enums/modo_redondeo.dart';
import '../errors/error_division.dart';

class CalcularDivision {
  RespuestaDivision ejecutar(
    EntradaCuenta entrada,
    EstrategiaRedondeo estrategiaRedondeo,
    ModoRedondeo modoRedondeo,
  ) {
    if (!entrada.monto.isFinite) {
      return const DivisionFallida(ErrorDivision.montoInvalido);
    }

    if (entrada.monto < 0) {
      return const DivisionFallida(ErrorDivision.montoNegativo);
    }

    if (entrada.personas < 1) {
      return const DivisionFallida(ErrorDivision.personasInsuficientes);
    }

    if (!entrada.porcentajePropina.isFinite) {
      return const DivisionFallida(ErrorDivision.propinaInvalida);
    }

    if (entrada.porcentajePropina < 0 || entrada.porcentajePropina > 100) {
      return const DivisionFallida(ErrorDivision.propinaFueraDeRango);
    }

    final propina = entrada.monto * entrada.porcentajePropina / 100;
    final totalCuenta = entrada.monto + propina;
    final importeSinRedondear = totalCuenta / entrada.personas;

    final montoPorPersona = estrategiaRedondeo.redondear(importeSinRedondear);

    return DivisionExitosa(
      ResultadoDivision(
        totalCuenta: totalCuenta,
        propina: propina,
        montoPorPersona: montoPorPersona,
        modoRedondeo: modoRedondeo,
      ),
    );
  }
}
