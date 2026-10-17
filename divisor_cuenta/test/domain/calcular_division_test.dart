import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_cuenta/data/strategies/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/strategies/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/errors/error_division.dart';
import 'package:divisor_cuenta/domain/enums/modo_redondeo.dart';
import 'package:divisor_cuenta/domain/entities/entrada_cuenta.dart';
import 'package:divisor_cuenta/domain/entities/respuesta_division.dart';
import 'package:divisor_cuenta/domain/use_cases/calcular_division.dart';

void main() {
  late CalcularDivision calcularDivision;
  const redondeoExacto = RedondeoExacto();
  const redondeoHaciaArriba = RedondeoHaciaArriba();

  setUp(() {
    calcularDivision = CalcularDivision();
  });

  group('CalcularDivision en modo exacto', () {
    test('divide una cuenta con propina', () {
      final entrada = EntradaCuenta(
        monto: 100,
        personas: 4,
        porcentajePropina: 10,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoExacto,
        ModoRedondeo.exacto,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.totalCuenta, 110);
      expect(resultado.propina, 10);
      expect(resultado.montoPorPersona, 27.50);
    });

    test('divide exactamente sin propina', () {
      final entrada = EntradaCuenta(
        monto: 90,
        personas: 3,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoExacto,
        ModoRedondeo.exacto,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 30.00);
    });

    test('redondea a dos decimales una división periódica', () {
      final entrada = EntradaCuenta(
        monto: 10,
        personas: 3,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoExacto,
        ModoRedondeo.exacto,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 3.33);
    });

    group('Validaciones de CalcularDivision', () {
      test('rechaza un monto negativo', () {
        final entrada = EntradaCuenta(
          monto: -1,
          personas: 2,
          porcentajePropina: 0,
        );

        final respuesta = calcularDivision.ejecutar(
          entrada,
          redondeoExacto,
          ModoRedondeo.exacto,
        );

        expect(respuesta, isA<DivisionFallida>());
        expect(
          (respuesta as DivisionFallida).error,
          ErrorDivision.montoNegativo,
        );
      });

      test('rechaza cero personas', () {
        final entrada = EntradaCuenta(
          monto: 100,
          personas: 0,
          porcentajePropina: 0,
        );

        final respuesta = calcularDivision.ejecutar(
          entrada,
          redondeoExacto,
          ModoRedondeo.exacto,
        );

        expect(respuesta, isA<DivisionFallida>());
        expect(
          (respuesta as DivisionFallida).error,
          ErrorDivision.personasInsuficientes,
        );
      });

      test('rechaza una propina inferior a cero', () {
        final entrada = EntradaCuenta(
          monto: 100,
          personas: 2,
          porcentajePropina: -1,
        );

        final respuesta = calcularDivision.ejecutar(
          entrada,
          redondeoExacto,
          ModoRedondeo.exacto,
        );

        expect(respuesta, isA<DivisionFallida>());
        expect(
          (respuesta as DivisionFallida).error,
          ErrorDivision.propinaFueraDeRango,
        );
      });

      test('rechaza una propina superior a cien', () {
        final entrada = EntradaCuenta(
          monto: 100,
          personas: 2,
          porcentajePropina: 101,
        );

        final respuesta = calcularDivision.ejecutar(
          entrada,
          redondeoExacto,
          ModoRedondeo.exacto,
        );

        expect(respuesta, isA<DivisionFallida>());
        expect(
          (respuesta as DivisionFallida).error,
          ErrorDivision.propinaFueraDeRango,
        );
      });
    });

    test('redondea la mitad decimal hacia arriba', () {
      final entrada = EntradaCuenta(
        monto: 2.01,
        personas: 2,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoExacto,
        ModoRedondeo.exacto,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 1.01);
    });

    test('redondea hacia arriba cuando el importe tiene decimales', () {
      final entrada = EntradaCuenta(
        monto: 10,
        personas: 3,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoHaciaArriba,
        ModoRedondeo.redondeoHaciaArriba,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 4.0);
    });

    test('mantiene el importe cuando el resultado ya es entero', () {
      final entrada = EntradaCuenta(
        monto: 90,
        personas: 3,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoHaciaArriba,
        ModoRedondeo.redondeoHaciaArriba,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 30.0);
    });

    test('redondea 1.005 hacia arriba a 1.01', () {
      final entrada = EntradaCuenta(
        monto: 2.01,
        personas: 2,
        porcentajePropina: 0,
      );

      final respuesta = calcularDivision.ejecutar(
        entrada,
        redondeoExacto,
        ModoRedondeo.exacto,
      );

      expect(respuesta, isA<DivisionExitosa>());

      final resultado = (respuesta as DivisionExitosa).resultado;
      expect(resultado.montoPorPersona, 1.01);
    });
  });
}
