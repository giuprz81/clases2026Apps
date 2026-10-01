import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final GoTrueClient _auth;

  SupabaseAuthRepository({GoTrueClient? auth})
      : _auth = auth ?? Supabase.instance.client.auth;

  @override
  Future<String> registrar(String correo, String clave) async {
    final respuesta = await _auth.signUp(email: correo, password: clave);
    final id = respuesta.user?.id;
    if (id == null) throw Exception('No fue posible crear la cuenta.');
    return id;
  }

  @override
  Future<void> ingresar(String correo, String clave) async {
    await _auth.signInWithPassword(email: correo, password: clave);
  }

  @override
  Future<void> salir() => _auth.signOut();

  @override
  String? obtenerIdActual() => _auth.currentUser?.id;
}
