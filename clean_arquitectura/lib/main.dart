import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_perfiles_repository.dart';
import 'domain/usecases/registrar_usuario.dart';
import 'presentation/pantallas/pantalla_ingreso.dart';
import 'presentation/providers/perfiles_provider.dart';
import 'presentation/providers/sesion_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  final authRepo = SupabaseAuthRepository();
  final perfilesRepo = SupabasePerfilesRepository();
  final registrarUsuario = RegistrarUsuario(authRepo, perfilesRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SesionProvider(authRepo, registrarUsuario),
        ),
        ChangeNotifierProvider(create: (_) => PerfilesProvider(perfilesRepo)),
      ],
      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Usuarios USFQ',
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    home: const PantallaIngreso(),
  );
}
