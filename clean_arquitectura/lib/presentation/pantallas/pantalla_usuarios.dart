import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/perfiles_provider.dart';
import '../providers/sesion_provider.dart';
import 'pantalla_ingreso.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PerfilesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final perfiles = context.watch<PerfilesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios registrados'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: perfiles.cargando
                ? null
                : () => context.read<PerfilesProvider>().cargar(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<SesionProvider>().salir();
              if (!context.mounted || context.read<SesionProvider>().error != null) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PantallaIngreso()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (perfiles.cargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (perfiles.error != null) {
            return Center(
              child: Text(perfiles.error!, style: const TextStyle(color: Colors.red)),
            );
          }
          return ListView.builder(
            itemCount: perfiles.perfiles.length,
            itemBuilder: (context, index) {
              final perfil = perfiles.perfiles[index];
              return ListTile(
                title: Text(perfil.nombre),
                subtitle: Text(perfil.creadoEn.toLocal().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
