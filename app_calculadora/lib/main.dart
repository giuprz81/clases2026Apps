import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: VibeTipCalculator());
}

class VibeTipCalculator extends StatefulWidget {
  const VibeTipCalculator({super.key});
  @override
  State<VibeTipCalculator> createState() => _VibeTipCalculatorState();
}

class _VibeTipCalculatorState extends State<VibeTipCalculator> {
  // 1. Variables de estado
  double bill = 0;
  double tipPercent = 15;
  int numberOfPeople = 1;
  bool roundTotal = false;

  // 2. Agentic Engineering: Matemáticas separadas del diseño
  double get tipAmount => bill * (tipPercent / 100);

  double get totalAmount {
    double total = bill + tipAmount;
    return roundTotal ? total.roundToDouble() : total;
  }

  double get totalPerPerson => totalAmount / numberOfPeople;

  // 3. Diseño visual (Interfaz)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculadora Limpia")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto de la cuenta (\$)',
              ),
              onChanged: (value) {
                setState(() {
                  bill = double.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Propina: ${tipPercent.toStringAsFixed(0)}%'),
            Slider(
              value: tipPercent,
              min: 0,
              max: 30,
              onChanged: (value) {
                setState(() {
                  tipPercent = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Dividir entre: $numberOfPeople personas'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (numberOfPeople > 1) numberOfPeople--;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      numberOfPeople++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Aquí está tu nuevo botón de redondeo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Redondear total'),
                Switch(
                  value: roundTotal,
                  onChanged: (value) {
                    setState(() {
                      roundTotal = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Textos visuales que ahora solo leen los resultados, sin hacer matemáticas
            Text(
              'Total Propina: \$${tipAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            Text(
              'Total a Pagar: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Total por Persona: \$${totalPerPerson.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
