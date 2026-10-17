import 'package:flutter/material.dart';

import '../../domain/entities/resultado_division.dart';
import '../../domain/enums/modo_redondeo.dart';

class ResumenDivision extends StatelessWidget {
  final ResultadoDivision resultado;

  const ResumenDivision({super.key, required this.resultado});

  String _formatearImporte(double importe) {
    return importe.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final esRedondeoHaciaArriba =
        resultado.modoRedondeo == ModoRedondeo.redondeoHaciaArriba;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Resumen de la cuenta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _FilaImporte(
              etiqueta: 'Monto original',
              importe: resultado.totalCuenta - resultado.propina,
            ),
            const SizedBox(height: 12),
            _FilaImporte(etiqueta: 'Propina', importe: resultado.propina),
            const Divider(height: 28),
            _FilaImporte(
              etiqueta: 'Total de la cuenta',
              importe: resultado.totalCuenta,
              destacado: true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'IMPORTE POR PERSONA',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_formatearImporte(resultado.montoPorPersona)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    esRedondeoHaciaArriba
                        ? 'Modo: redondeo hacia arriba'
                        : 'Modo: exacto',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaImporte extends StatelessWidget {
  final String etiqueta;
  final double importe;
  final bool destacado;

  const _FilaImporte({
    required this.etiqueta,
    required this.importe,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontSize: destacado ? 16 : 14,
      fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(etiqueta, style: estilo)),
        const SizedBox(width: 12),
        Text('\$${importe.toStringAsFixed(2)}', style: estilo),
      ],
    );
  }
}
