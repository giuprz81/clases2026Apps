import 'package:flutter/material.dart';

import '../domain/entities/usuario.dart';
import '../domain/usecases/obtener_usuarios_con_vocal.dart';

class PantallaUsuarios extends StatefulWidget {
  final ObtenerUsuariosConVocal obtenerUsuariosConVocal;

  const PantallaUsuarios({
    super.key,
    required this.obtenerUsuariosConVocal,
  });

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  late final Future<List<Usuario>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = widget.obtenerUsuariosConVocal();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Usuarios (Clean Architecture)')),
    body: FutureBuilder<List<Usuario>>(
      future: futureUsuarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay usuarios'));
        }
        final usuarios = snapshot.data!;
        return ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final usuario = usuarios[index];
            return ListTile(
              leading: CircleAvatar(child: Text(usuario.id.toString())),
              title: Text(usuario.nombre),
              subtitle: Text(usuario.email),
            );
          },
        );
      },
    ),
  );
}
