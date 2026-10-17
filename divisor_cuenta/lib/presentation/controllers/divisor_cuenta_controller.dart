import '../../data/strategies/redondeo_exacto.dart';
import '../../data/strategies/redondeo_hacia_arriba.dart';
import '../../domain/entities/entrada_cuenta.dart';
import '../../domain/entities/respuesta_division.dart';
import '../../domain/enums/modo_redondeo.dart';
import '../../domain/errors/error_division.dart';
import '../../domain/use_cases/calcular_division.dart';
import '../../domain/entities/resultado_division.dart';

class DivisorCuentaController {
  final CalcularDivision _calcularDivision;
  final RedondeoExacto _redondeoExacto;
  final RedondeoHaciaArriba _redondeoHaciaArriba;

  String? mensajeError;
  ResultadoDivision? resultado;

  DivisorCuentaController(
    this._calcularDivision, {
    required this._redondeoExacto,
    required this._redondeoHaciaArriba,
  });

  void calcular({
    required String textoMonto,
    required String textoPersonas,
    required String textoPropina,
    required ModoRedondeo modoRedondeo,
  }) {
    mensajeError = null;
    resultado = null;

    final montoTexto = textoMonto.trim();
    final personasTexto = textoPersonas.trim();
    final propinaTexto = textoPropina.trim();

    if (montoTexto.isEmpty ||
        montoTexto.contains(',') ||
        double.tryParse(montoTexto) == null) {
      mensajeError = ErrorDivision.montoInvalido.mensaje;
      return;
    }

    final monto = double.parse(montoTexto);

    if (monto < 0) {
      mensajeError = ErrorDivision.montoNegativo.mensaje;
      return;
    }

    if (personasTexto.isEmpty) {
      mensajeError = ErrorDivision.personasInsuficientes.mensaje;
      return;
    }

    final personas = int.tryParse(personasTexto);

    if (personas == null) {
      mensajeError = ErrorDivision.personasNoEnteras.mensaje;
      return;
    }

    if (personas < 1) {
      mensajeError = ErrorDivision.personasInsuficientes.mensaje;
      return;
    }

    if (propinaTexto.isEmpty ||
        propinaTexto.contains(',') ||
        double.tryParse(propinaTexto) == null) {
      mensajeError = ErrorDivision.propinaInvalida.mensaje;
      return;
    }

    final porcentajePropina = double.parse(propinaTexto);

    if (porcentajePropina < 0 || porcentajePropina > 100) {
      mensajeError = ErrorDivision.propinaFueraDeRango.mensaje;
      return;
    }

    final estrategiaRedondeo = switch (modoRedondeo) {
      ModoRedondeo.exacto => _redondeoExacto,
      ModoRedondeo.redondeoHaciaArriba => _redondeoHaciaArriba,
    };

    final respuesta = _calcularDivision.ejecutar(
      EntradaCuenta(
        monto: monto,
        personas: personas,
        porcentajePropina: porcentajePropina,
      ),
      estrategiaRedondeo,
      modoRedondeo,
    );

    switch (respuesta) {
      case DivisionExitosa(:final resultado):
        this.resultado = resultado;
      case DivisionFallida(:final error):
        mensajeError = error.mensaje;
    }
  }
}
