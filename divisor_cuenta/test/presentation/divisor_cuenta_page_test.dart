import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_cuenta/data/strategies/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/strategies/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/use_cases/calcular_division.dart';
import 'package:divisor_cuenta/domain/enums/modo_redondeo.dart';
import 'package:divisor_cuenta/presentation/pages/divisor_cuenta_page.dart';

void main() {
  group('DivisorCuentaPage', () {
    testWidgets('muestra el resultado exacto al introducir datos válidos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(1), '4');
      await tester.enterText(find.byType(TextField).at(2), '10');
      await tester.pumpAndSettle();

      expect(find.text('\$27.50'), findsOneWidget);
      expect(find.text('Modo: exacto'), findsOneWidget);
    });

    testWidgets('actualiza el resultado cuando cambia el monto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '90');
      await tester.enterText(find.byType(TextField).at(1), '3');
      await tester.enterText(find.byType(TextField).at(2), '0');
      await tester.pumpAndSettle();

      expect(find.text('\$30.00'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '10');
      await tester.pumpAndSettle();

      expect(find.text('\$3.33'), findsOneWidget);
      expect(find.text('\$30.00'), findsNothing);
    });

    testWidgets('actualiza el resultado al cambiar a redondeo hacia arriba', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '10');
      await tester.enterText(find.byType(TextField).at(1), '3');
      await tester.enterText(find.byType(TextField).at(2), '0');
      await tester.pumpAndSettle();

      expect(find.text('\$3.33'), findsOneWidget);

      await tester.tap(find.byType(RadioListTile<ModoRedondeo>).last);
      await tester.pumpAndSettle();

      expect(find.text('\$4.00'), findsOneWidget);
      expect(find.text('Modo: redondeo hacia arriba'), findsOneWidget);
    });
    testWidgets(
      'muestra error y oculta el importe cuando el monto está vacío',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DivisorCuentaPage(
              calcularDivision: CalcularDivision(),
              redondeoExacto: const RedondeoExacto(),
              redondeoHaciaArriba: const RedondeoHaciaArriba(),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField).at(1), '2');
        await tester.enterText(find.byType(TextField).at(2), '0');

        expect(find.text('Monto invalido'), findsOneWidget);
        expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
      },
    );

    testWidgets('rechaza la coma decimal y oculta el importe por persona', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '12,50');
      await tester.pumpAndSettle();

      expect(find.text('Monto invalido'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza cero personas y oculta el importe por persona', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(1), '0');
      await tester.pumpAndSettle();

      expect(find.text('Debe haber al menos una persona'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza personas no enteras y oculta el importe por persona', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(1), '2.5');
      await tester.pumpAndSettle();

      expect(
        find.text('El número de personas debe ser un entero'),
        findsOneWidget,
      );
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza un monto negativo y oculta el importe por persona', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '-10');
      await tester.pumpAndSettle();

      expect(find.text('El monto no puede ser negativo'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza una propina vacía', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(2), '');
      await tester.pumpAndSettle();

      expect(find.text('Propina invalida'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza una propina no numérica', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(2), 'abc');
      await tester.pumpAndSettle();

      expect(find.text('Propina invalida'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });

    testWidgets('rechaza una propina superior a cien', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DivisorCuentaPage(
            calcularDivision: CalcularDivision(),
            redondeoExacto: const RedondeoExacto(),
            redondeoHaciaArriba: const RedondeoHaciaArriba(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(2), '101');
      await tester.pumpAndSettle();

      expect(find.text('La propina debe estar entre 0 y 100'), findsOneWidget);
      expect(find.textContaining('IMPORTE POR PERSONA'), findsNothing);
    });
  });
}
