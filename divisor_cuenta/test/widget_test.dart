import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_cuenta/main.dart';

void main() {
  testWidgets('Divide una cuenta y muestra el importe por persona', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Divisor de cuenta'), findsOneWidget);

    final campos = find.byType(TextField);

    await tester.enterText(campos.at(0), '100');
    await tester.pumpAndSettle();

    await tester.enterText(campos.at(1), '4');
    await tester.pumpAndSettle();

    await tester.enterText(campos.at(2), '10');
    await tester.pumpAndSettle();

    expect(find.text('\$27.50'), findsOneWidget);
    expect(find.text('IMPORTE POR PERSONA'), findsOneWidget);
  });
}
