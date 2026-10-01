import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/perfil.dart';
import '../../domain/repositories/perfiles_repository.dart';

class SupabasePerfilesRepository implements PerfilesRepository {
  final SupabaseClient _cliente;

  SupabasePerfilesRepository({SupabaseClient? cliente})
      : _cliente = cliente ?? Supabase.instance.client;

  @override
  Future<void> crear(String id, String nombre) async {
    await _cliente.from('perfiles').insert({'id': id, 'nombre': nombre});
  }

  @override
  Future<List<Perfil>> obtenerTodos() async {
    final respuesta = await _cliente.from('perfiles').select().order('creado_en');
    return (respuesta as List<dynamic>).map((fila) {
      final datos = fila as Map<String, dynamic>;
      return Perfil(
        id: datos['id'] as String,
        nombre: datos['nombre'] as String,
        creadoEn: DateTime.parse(datos['creado_en'] as String),
      );
    }).toList();
  }
}
