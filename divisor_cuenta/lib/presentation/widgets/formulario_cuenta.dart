import 'package:flutter/material.dart';

import '../../domain/enums/modo_redondeo.dart';

class FormularioCuenta extends StatelessWidget {
  final TextEditingController controladorMonto;
  final TextEditingController controladorPersonas;
  final TextEditingController controladorPropina;
  final ModoRedondeo modoRedondeo;
  final ValueChanged<ModoRedondeo> alCambiarModo;
  final VoidCallback alCambiarEntrada;

  const FormularioCuenta({
    super.key,
    required this.controladorMonto,
    required this.controladorPersonas,
    required this.controladorPropina,
    required this.modoRedondeo,
    required this.alCambiarModo,
    required this.alCambiarEntrada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controladorMonto,
          onChanged: (_) => alCambiarEntrada(),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Monto de la cuenta',
            hintText: 'Ej. 100.50',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controladorPersonas,
          onChanged: (_) => alCambiarEntrada(),
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            labelText: 'Número de personas',
            hintText: 'Ej. 4',
            prefixIcon: Icon(Icons.people),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controladorPropina,
          onChanged: (_) => alCambiarEntrada(),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Propina (%)',
            hintText: 'Ej. 10',
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Modo de cálculo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RadioGroup<ModoRedondeo>(
          groupValue: modoRedondeo,
          onChanged: (nuevoModo) {
            if (nuevoModo != null) {
              alCambiarModo(nuevoModo);
            }
          },
          child: const Column(
            children: [
              RadioListTile<ModoRedondeo>(
                value: ModoRedondeo.exacto,
                title: Text('Exacto'),
                subtitle: Text('Redondea a dos decimales'),
              ),
              RadioListTile<ModoRedondeo>(
                value: ModoRedondeo.redondeoHaciaArriba,
                title: Text('Redondeo hacia arriba'),
                subtitle: Text(
                  'Eleva el importe individual al entero superior',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
