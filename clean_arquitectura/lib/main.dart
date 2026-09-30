import 'package:flutter/material.dart';

import 'data/repositories/usuario_memoria.dart';
import 'domain/usecases/obtener_usuarios_con_vocal.dart';
import 'presentation/pantalla_usuarios.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Punto de composición: cambiar a UsuarioApi no afecta UI ni dominio.
    final casoDeUso = ObtenerUsuariosConVocal(UsuarioMemoria());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Arquitectura',
      home: PantallaUsuarios(obtenerUsuariosConVocal: casoDeUso),
    );
  }
}
