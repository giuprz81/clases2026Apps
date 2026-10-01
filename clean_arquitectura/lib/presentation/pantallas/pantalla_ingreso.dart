import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sesion_provider.dart';
import 'pantalla_usuarios.dart';

class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _nombre = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    if (sesion.idUsuario != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PantallaUsuarios()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar o crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _clave,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 24),
            if (sesion.cargando) const CircularProgressIndicator(),
            if (sesion.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(sesion.error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: sesion.cargando
                  ? null
                  : () => context.read<SesionProvider>().ingresar(
                        _correo.text.trim(),
                        _clave.text,
                      ),
              child: const Text('Ingresar'),
            ),
            OutlinedButton(
              onPressed: sesion.cargando
                  ? null
                  : () => context.read<SesionProvider>().registrar(
                        _correo.text.trim(),
                        _clave.text,
                        _nombre.text.trim(),
                      ),
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
