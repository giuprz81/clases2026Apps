import 'package:divisor_cuenta/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calcula el valor que paga cada persona', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());

    await tester.enterText(find.byKey(const Key('amountField')), '100');
    await tester.pump();

    final addPerson = find.byKey(const Key('addPerson'));
    await tester.ensureVisible(addPerson);
    await tester.tap(addPerson);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('perPersonAmount')), findsOneWidget);
    expect(find.text('\$36.67'), findsOneWidget);
  });

  testWidgets('no permite menos de una persona', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());

    final removePerson = find.byKey(const Key('removePerson'));
    await tester.tap(removePerson);
    await tester.pump();
    await tester.tap(removePerson);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
