// lib/data/repositories/usuario_repository_impl.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

// Esta clase "cumple" (implements) el contrato que definimos en el Dominio.
class UsuarioRepositoryImpl implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtenerUsuarios() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      // 1. Parseamos el texto JSON a una lista dinámica
      final List<dynamic> datosJson = jsonDecode(respuesta.body);

      // 2. Transformamos (mapeamos) cada pedazo de JSON a nuestra entidad Usuario
      return datosJson
          .map(
            (json) => Usuario(
              id: json['id'],
              nombre: json['name'],
              email: json['email'],
            ),
          )
          .toList();
    } else {
      throw Exception('Error al cargar usuarios desde la API');
    }
  }
}
