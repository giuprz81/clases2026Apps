import 'package:flutter/material.dart';

import '../../data/strategies/redondeo_exacto.dart';
import '../../data/strategies/redondeo_hacia_arriba.dart';
import '../../domain/enums/modo_redondeo.dart';
import '../controllers/divisor_cuenta_controller.dart';
import '../widgets/formulario_cuenta.dart';
import '../widgets/resumen_division.dart';
import '../../domain/use_cases/calcular_division.dart';

class DivisorCuentaPage extends StatefulWidget {
  const DivisorCuentaPage({
    super.key,
    required this.calcularDivision,
    required this.redondeoExacto,
    required this.redondeoHaciaArriba,
  });

  final CalcularDivision calcularDivision;
  final RedondeoExacto redondeoExacto;
  final RedondeoHaciaArriba redondeoHaciaArriba;

  @override
  State<DivisorCuentaPage> createState() => _DivisorCuentaPageState();
}

class _DivisorCuentaPageState extends State<DivisorCuentaPage> {
  final _controladorMonto = TextEditingController();
  final _controladorPersonas = TextEditingController(text: '2');
  final _controladorPropina = TextEditingController(text: '0');

  late final DivisorCuentaController _controladorDivision;

  ModoRedondeo _modoRedondeo = ModoRedondeo.exacto;
  @override
  void initState() {
    super.initState();
    _controladorDivision = DivisorCuentaController(
      widget.calcularDivision,
      redondeoExacto: widget.redondeoExacto,
      redondeoHaciaArriba: widget.redondeoHaciaArriba,
    );

    _controladorDivision.calcular(
      textoMonto: _controladorMonto.text,
      textoPersonas: _controladorPersonas.text,
      textoPropina: _controladorPropina.text,
      modoRedondeo: _modoRedondeo,
    );
  }

  @override
  void dispose() {
    _controladorMonto.dispose();
    _controladorPersonas.dispose();
    _controladorPropina.dispose();
    super.dispose();
  }

  void _actualizarDivision() {
    setState(() {
      _controladorDivision.calcular(
        textoMonto: _controladorMonto.text,
        textoPersonas: _controladorPersonas.text,
        textoPropina: _controladorPropina.text,
        modoRedondeo: _modoRedondeo,
      );
    });
  }

  void _cambiarModo(ModoRedondeo nuevoModo) {
    setState(() {
      _modoRedondeo = nuevoModo;
      _controladorDivision.calcular(
        textoMonto: _controladorMonto.text,
        textoPersonas: _controladorPersonas.text,
        textoPropina: _controladorPropina.text,
        modoRedondeo: _modoRedondeo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _controladorDivision.resultado;
    final mensajeError = _controladorDivision.mensajeError;

    return Scaffold(
      appBar: AppBar(title: const Text('Divisor de cuenta'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Divide la cuenta fácilmente',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa el monto, las personas y la propina '
                    'para calcular cuánto debe pagar cada uno.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FormularioCuenta(
                    controladorMonto: _controladorMonto,
                    controladorPersonas: _controladorPersonas,
                    controladorPropina: _controladorPropina,
                    modoRedondeo: _modoRedondeo,
                    alCambiarModo: _cambiarModo,
                    alCambiarEntrada: _actualizarDivision,
                  ),
                  if (mensajeError != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mensajeError,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (resultado != null) ...[
                    const SizedBox(height: 24),
                    ResumenDivision(resultado: resultado),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
