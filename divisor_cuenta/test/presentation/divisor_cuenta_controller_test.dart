import 'package:flutter_test/flutter_test.dart';

import 'package:divisor_cuenta/data/strategies/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/strategies/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/enums/modo_redondeo.dart';
import 'package:divisor_cuenta/domain/errors/error_division.dart';
import 'package:divisor_cuenta/domain/use_cases/calcular_division.dart';
import 'package:divisor_cuenta/presentation/controllers/divisor_cuenta_controller.dart';

void main() {
  late DivisorCuentaController controlador;

  setUp(() {
    controlador = DivisorCuentaController(
      CalcularDivision(),
      redondeoExacto: const RedondeoExacto(),
      redondeoHaciaArriba: const RedondeoHaciaArriba(),
    );
  });

  group('DivisorCuentaController', () {
    test('calcula correctamente una cuenta válida', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '4',
        textoPropina: '10',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, isNull);
      expect(controlador.resultado, isNotNull);
      expect(controlador.resultado!.totalCuenta, 110);
      expect(controlador.resultado!.propina, 10);
      expect(controlador.resultado!.montoPorPersona, 27.50);
    });

    test('rechaza un monto vacío', () {
      controlador.calcular(
        textoMonto: '',
        textoPersonas: '2',
        textoPropina: '10',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, ErrorDivision.montoInvalido.mensaje);
      expect(controlador.resultado, isNull);
    });

    test('rechaza un monto con coma decimal', () {
      controlador.calcular(
        textoMonto: '10,50',
        textoPersonas: '2',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, ErrorDivision.montoInvalido.mensaje);
      expect(controlador.resultado, isNull);
    });

    test('rechaza un monto negativo', () {
      controlador.calcular(
        textoMonto: '-10',
        textoPersonas: '2',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, ErrorDivision.montoNegativo.mensaje);
      expect(controlador.resultado, isNull);
    });

    test('rechaza un número de personas que no es entero', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '2.5',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, ErrorDivision.personasNoEnteras.mensaje);
      expect(controlador.resultado, isNull);
    });

    test('rechaza cero personas', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '0',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(
        controlador.mensajeError,
        ErrorDivision.personasInsuficientes.mensaje,
      );
      expect(controlador.resultado, isNull);
    });
    test('rechaza una propina fuera del rango permitido', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '2',
        textoPropina: '101',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(
        controlador.mensajeError,
        ErrorDivision.propinaFueraDeRango.mensaje,
      );
      expect(controlador.resultado, isNull);
    });

    test('rechaza una propina superior al 100%', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '4',
        textoPropina: '150',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(
        controlador.mensajeError,
        'La propina no puede superar el 100%',
      );
    });

    test('acepta una propina del 100%', () {
      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '4',
        textoPropina: '100',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, isNull);
    });

    test('limpia el error anterior cuando el cálculo es válido', () {
      controlador.calcular(
        textoMonto: '',
        textoPersonas: '2',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, isNotNull);

      controlador.calcular(
        textoMonto: '100',
        textoPersonas: '2',
        textoPropina: '0',
        modoRedondeo: ModoRedondeo.exacto,
      );

      expect(controlador.mensajeError, isNull);
      expect(controlador.resultado, isNotNull);
      expect(controlador.resultado!.montoPorPersona, 50);
    });
  });
}
